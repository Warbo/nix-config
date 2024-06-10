set -e

# Put YouTube video in a download queue
cd ~/Downloads/VIDEOS || exit 1  # Save to Downloads/VIDEOS
# Use best quality less than 600p (avoids massive filesize)
ts yt-dlp -f 'b[height<600]' "$@"
