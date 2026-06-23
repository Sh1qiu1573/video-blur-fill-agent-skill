#!/usr/bin/env bash
# ============================================================
#  video-blur-fill / batch-blur-fill.sh
#  Blur-fill video resizer — outputs multiple social-media
#  resolutions with a blurred-background fill.
# ============================================================
set -euo pipefail

FFMPEG="${FFMPEG:-ffmpeg}"
CRF="${CRF:-23}"
PRESET="${PRESET:-medium}"

# ---- target resolutions (name:WxH) ----
declare -a RESOLUTIONS=(
  "landscape_720p:1280:720"
  "square_1080p:1080:1080"
  "portrait_4x5:1080:1350"
  "portrait_9x16:720:1280"
)

usage() {
  cat <<'EOF'
Usage: batch-blur-fill.sh [OPTIONS] <video-file...>

Options:
  -o, --outdir DIR       Output directory (default: same as input)
  -r, --resolution NAME  Only process a single resolution
                         (landscape_720p,square_1080p,portrait_4x5,portrait_9x16)
  -l, --list             List available resolutions
  -h, --help             Show help

Examples:
  batch-blur-fill.sh video.mp4
  batch-blur-fill.sh -o ./out video.mp4
  batch-blur-fill.sh -r square_1080p *.mp4
EOF
  exit 0
}

# ---- parse args ----
INPUT_FILES=()
OUTDIR=""
TARGET_RES=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--outdir) OUTDIR="$2"; shift 2 ;;
    -r|--resolution) TARGET_RES="$2"; shift 2 ;;
    -l|--list)
      echo "Available resolutions:"
      for r in "${RESOLUTIONS[@]}"; do
        IFS=':' read -r name w h <<< "$r"
        printf "  %-18s %s×%s\n" "$name" "$w" "$h"
      done
      exit 0
      ;;
    -h|--help) usage ;;
    -*) echo "Unknown option: $1" >&2; usage ;;
    *) INPUT_FILES+=("$1"); shift ;;
  esac
done

if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
  echo "Error: at least one video file required." >&2
  usage
fi

# ---- filter resolutions ----
FILTERED=()
if [[ -z "$TARGET_RES" ]]; then
  FILTERED=("${RESOLUTIONS[@]}")
else
  for r in "${RESOLUTIONS[@]}"; do
    IFS=':' read -r name w h <<< "$r"
    if [[ "$name" == "$TARGET_RES" ]]; then
      FILTERED+=("$r")
      break
    fi
  done
  if [[ ${#FILTERED[@]} -eq 0 ]]; then
    echo "Error: unknown resolution '$TARGET_RES'" >&2
    exit 1
  fi
fi

# ---- core: process one video → one resolution ----
process_one() {
  local input="$1" name="$2" tw="$3" th="$4" outdir="$5"

  local base stem suffix
  base=$(basename "$input")
  stem="${base%.*}"
  suffix="${base##*.}"
  [[ "$suffix" == "$base" ]] && suffix="mp4"

  local output="${outdir}/${stem}_${name}.${suffix}"

  echo "→ ${stem}_${name}.${suffix}  |  ${tw}×${th}"

  # filter chain:
  #   split=2 → [bg] (background, blurred + dimmed) + [fg] (foreground, scaled to fit)
  #   bg: scale+crop to fill → boxblur=10:5 → brightness -0.1
  #   fg: scale to fit inside target
  #   overlay: centre fg on bg
  "$FFMPEG" -y -i "$input" \
    -filter_complex \
      "[0:v]split=2[bg][fg];\
       [bg]scale=${tw}:${th}:force_original_aspect_ratio=increase,crop=${tw}:${th},boxblur=10:5,eq=brightness=-0.1[bg_blurred];\
       [fg]scale=${tw}:${th}:force_original_aspect_ratio=decrease[fg_scaled];\
       [bg_blurred][fg_scaled]overlay=(W-w)/2:(H-h)/2" \
    -c:v libx264 -preset "$PRESET" -crf "$CRF" \
    -c:a aac -b:a 128k \
    -movflags +faststart \
    -pix_fmt yuv420p \
    "$output"

  echo "  ✓ done: $output"
}

# ---- main ----
total=${#INPUT_FILES[@]}
idx=0

for input in "${INPUT_FILES[@]}"; do
  idx=$((idx + 1))

  if [[ ! -f "$input" ]]; then
    echo "⚠ skip: '$input' is not a file" >&2
    continue
  fi

  if [[ -z "$OUTDIR" ]]; then
    outdir=$(dirname "$(realpath "$input")")
  else
    outdir="$OUTDIR"
  fi
  mkdir -p "$outdir"

  echo ""
  echo "═══════════════════════════════════════════"
  echo "📹 [$idx/$total] $(basename "$input")"
  echo "═══════════════════════════════════════════"

  for preset in "${FILTERED[@]}"; do
    IFS=':' read -r pname pw ph <<< "$preset"
    process_one "$input" "$pname" "$pw" "$ph" "$outdir"
  done
done

echo ""
echo "🎉 All done! Processed $total file(s)."
