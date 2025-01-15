#/bin/bash
echo "Script Launched !"
tar -czvf /mnt/music_backup/music_$(date +'%y%m%d_%H%M%S').tar.gz /srv/music
echo "If you don't have big red text on your screen, everything went well !"
