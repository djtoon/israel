"""Mux the finished picture with the mix into the master: H.264 High (crf 16, slow), AAC 320k, faststart.
   python -I master.py picture.mp4 mix.wav out.mp4"""
import subprocess, sys
pic, mix, out = sys.argv[1:4]
subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", pic, "-i", mix, "-map", "0:v", "-map", "1:a",
                "-c:v", "libx264", "-preset", "slow", "-crf", "16", "-profile:v", "high", "-pix_fmt", "yuv420p",
                "-tune", "film", "-x264-params", "aq-mode=3", "-c:a", "aac", "-b:a", "320k", "-ar", "48000",
                "-movflags", "+faststart", "-t", "102", out], check=True)
print("wrote", out)
