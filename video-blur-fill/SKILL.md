---
name: video-blur-fill
description: "Batch-resize videos to social-media resolutions (1280×720, 1080×1080, 1080×1350, 720×1280) with blurred-background fill. Use when the user needs to convert videos for multiple platforms, resize with blur-fill, create square/portrait/landscape video variants, or batch-process video files into social-media-friendly formats."
---

# Video Blur-Fill

Batch-convert video files to multiple social-media resolutions using a blurred-background fill technique. The foreground is centred and scaled to fit; the background is a dimmed, blurred copy that fills the remaining area.

## Target resolutions

| Name            | Width | Height | Typical use          |
|-----------------|-------|--------|-----------------------|
| landscape_720p  | 1280  | 720    | 16:9 feeds / YouTube |
| square_1080p    | 1080  | 1080   | Instagram square     |
| portrait_4x5    | 1080  | 1350   | Instagram portrait   |
| portrait_9x16   | 720   | 1280   | Stories / Shorts     |

## Blur-fill parameters

- **boxblur**: `10:5` (luma_radius=10, chroma_radius=5)
- **brightness**: `-0.1` on the blurred background layer (slightly dimmed so the foreground stands out)
- **CRF**: 23 (tune with `CRF` env var; lower = higher quality)
- **Preset**: medium (tune with `PRESET` env var)
- **Codec**: H.264 + AAC @ 128 kbps

## Workflow

1. Confirm the source video file(s) and output directory with the user.
2. Run the bundled script:
   ```bash
   bash scripts/batch-blur-fill.sh -o <output-dir> <video-file...>
   ```
3. The script produces one output file per resolution per input, named:
   `{stem}_{resolution_name}.{ext}`
4. Verify outputs exist and report the file listing.

## Options

- `-o, --outdir DIR` — output directory (default: same as input)
- `-r, --resolution NAME` — process only one resolution (useful for single-platform export)
- `-l, --list` — list available resolution names
- `CRF=18 PRESET=slow bash scripts/batch-blur-fill.sh …` — override quality/speed

## Notes

- Requires `ffmpeg` on PATH.
- Audio is re-encoded to AAC 128 kbps (stereo downmix safe).
- `-movflags +faststart` is set so outputs stream progressively.
- The script is deterministic — same input + same parameters always produce the same output.
- If the user requests different resolutions or blur parameters, edit the `RESOLUTIONS` array or the filter chain directly in the script.
