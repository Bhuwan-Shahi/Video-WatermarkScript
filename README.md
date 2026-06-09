logo_left.png
logo_right.png
   videos/
     video1.mp4
     video2.mp4
watermarked/       ← output goes here


//Execute the script
chmod +x batch_watermark.sh
./batch_watermark.sh


A few tips:

Logos should be PNGs with a transparent background for best results.
Change PADDING=20 to move logos closer to or further from the edges.
The script copies the audio track as-is (no re-encoding), so it's fast.
If a video fails, the script keeps going and processes the rest.
