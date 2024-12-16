#!/bin/bash

 
video_title=$(yt-dlp --quiet --no-warnings --get-title "$1")
mkdir "/opt/yt/downloads/$video_title/"
yt-dlp --quiet --no-warnings -o "/opt/yt/downloads/$video_title/%(title)s.mp4" "$1"
yt-dlp --quiet --no-warnings --get-description $1 >> "/opt/yt/downloads/$video_title/description"

echo "Video : $1 was downloaded"
echo "File Path : /opt/yt/downloads/$video_title/$video_title.mp4"

date=$(date '+%y-%m-%d %T')
echo "[$date] Video $1 was downloaded. File path : /opt/yt/downloads/$video_title/$video_title.mp4" >> "/var/log/yt/download.log"



