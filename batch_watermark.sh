#!/bin/bash

# ─────────────────────────────────────────
# CONFIGURATION — edit these paths
# ─────────────────────────────────────────
LOGO_LEFT="logo_left.png"       # Bottom-left logo
LOGO_RIGHT="logo_right.png"     # Bottom-right logo
INPUT_DIR="./videos"            # Folder containing your MP4s
OUTPUT_DIR="./watermarked"      # Where output videos will be saved
PADDING=20                      # Distance from edges in pixels
# ─────────────────────────────────────────

mkdir -p "$OUTPUT_DIR"

# Check logos exist
if [[ ! -f "$LOGO_LEFT" ]]; then
  echo "❌ Logo not found: $LOGO_LEFT"
  exit 1
fi
if [[ ! -f "$LOGO_RIGHT" ]]; then
  echo "❌ Logo not found: $LOGO_RIGHT"
  exit 1
fi

# Count videos (case-insensitive: matches .mp4 and .MP4)
total=$(find "$INPUT_DIR" -maxdepth 1 -iname "*.mp4" | wc -l)
if [[ $total -eq 0 ]]; then
  echo "❌ No MP4 files found in $INPUT_DIR"
  exit 1
fi

echo "🎬 Found $total video(s). Starting..."
count=0

while IFS= read -r INPUT; do
  FILENAME=$(basename "$INPUT")
  OUTPUT="$OUTPUT_DIR/$FILENAME"
  count=$((count + 1))

  echo "[$count/$total] Processing: $FILENAME"

  ffmpeg -y -i "$INPUT" \
    -i "$LOGO_LEFT" \
    -i "$LOGO_RIGHT" \
    -filter_complex "
      [1:v] scale=150:150:force_original_aspect_ratio=decrease,pad=150:150:(ow-iw)/2:(oh-ih)/2:color=0x00000000 [left];
      [2:v] scale=150:150:force_original_aspect_ratio=decrease,pad=150:150:(ow-iw)/2:(oh-ih)/2:color=0x00000000 [right];
      [0:v][left]  overlay=${PADDING}:${PADDING} [tmp];
      [tmp][right] overlay=W-w-${PADDING}:${PADDING}
    " \
    -codec:a copy \
    "$OUTPUT"

  if [[ $? -eq 0 ]]; then
    echo "  ✅ Done: $OUTPUT"
  else
    echo "  ❌ Failed: $FILENAME"
  fi
done < <(find "$INPUT_DIR" -maxdepth 1 -iname "*.mp4")

echo ""
echo "✅ All done! Watermarked videos saved to: $OUTPUT_DIR"
