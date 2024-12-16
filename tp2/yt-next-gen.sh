#!/bin/bash
while true
do
  LINE=$(head -n 1 "/opt/yt/urls.txt")
  if [[ ! $LINE =~ ^https://www\.youtube\.com/watch\?v=([a-z]|[A-Z]|[0-9]|'_'|'-'){11}$ ]]; then
    sed -i '1d' "/opt/yt/urls.txt"
  else
     if [ ! -f "/var/log/yt/download.log" ]; then
       echo "Pas de fichier logs, vérifiez /var/log/yt/downloads.log"
       exit
     fi

     VIDEO_TITLE=$(yt-dlp --quiet --no-warnings --get-title $LINE)
     VIDEO_TITLE="${VIDEO_TITLE// /_}"

     mkdir /opt/yt/downloads/${VIDEO_TITLE}
     yt-dlp --quiet --no-warnings --get-description "$LINE" >> /opt/yt/downloads/${VIDEO_TITLE}/description
     yt-dlp -f mp4 --quiet --no-warnings -o "/opt/yt/downloads/${VIDEO_TITLE}/${VIDEO_TITLE}.mp4" "$LINE"

     echo "Video : $LINE was downloaded."
     echo "File path: /opt/yt/downloads/$VIDEO_TITLE/$VIDEO_TITLE.mp4"

    date=$(date '+%y-%m-%d %T')
    echo "[$date] Video $LINE was downloaded. File path : /opt/yt/downloads/$video_title/$video_title.mp4" >> "/var/log/yt/download.log"
    sed -i '1d' "/opt/yt/urls.txt"
  fi
done < urls.txt
exit
