#!/bin/bash
while read LINE
do 
video_title=$(yt-dlp --quiet --no-warnings --get-title "$LINE")
mkdir "/opt/yt/downloads/$video_title/"
yt-dlp --quiet --no-warnings -o "/opt/yt/downloads/$video_title/%(title)s.mp4" "$LINE"
yt-dlp --quiet --no-warnings --get-description $LINE >> "/opt/yt/downloads/$video_title/description"

echo "Video : $LINE was downloaded"
echo "File Path : /opt/yt/downloads/$video_title/$video_title.mp4"

date=$(date '+%y-%m-%d %T')
echo "[$date] Video $LINE was downloaded. File path : /opt/yt/downloads/$video_title/$video_title.mp4" >> "/var/log/yt/download.log"
done < /opt/yt/urls.txt



