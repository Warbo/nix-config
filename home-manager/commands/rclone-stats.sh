# Poll our SFTP rclone mount for its disk usage and queue size
while true
do
    rclone rc --rc-addr :22222 vfs/stats |
        jq '.diskCache + {"MBs": (.diskCache.bytesUsed / 1000000)}'
    sleep 5
done
