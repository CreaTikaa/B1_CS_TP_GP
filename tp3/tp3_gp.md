# TP 3

### Partie II : Serveur de streaming

**1. Préparation de la machine**
```
[crea@music ~]$ cd /srv
[crea@music srv]$ sudo mkdir music
[sudo] password for crea:
[crea@music srv]$ ls
music
```
2/ Envoi des musiques
```
exemple commande scp : scp -P 24913 "C:\Users\creat\Music\musics\Hollow_Soul.mp3" crea@10.3.1.11:/home/crea 
[crea@music music]$ pwd
/srv/music
[crea@music music]$ ls
Hollow_Soul.mp3  Legends_Never_Die.mp3  True_Faith.mp3
```
**2. Installation du service de streaming**  
3/ Installation Jellyfin
```
[crea@music music]$ sudo dnf install jellyfin
[crea@music music]$ sudo systemctl start jellyfin
[crea@music music]$ systemctl status jellyfin
● jellyfin.service - Jellyfin Media Server
     Loaded: loaded (/usr/lib/systemd/system/jellyfin.service; disabled; pr>
    Drop-In: /etc/systemd/system/jellyfin.service.d
             └─override.conf
     Active: active (running) since Fri 2025-01-10 18:05:30 CET; 6s ago
```
2/ Afficher les ports TCP en écoutes
```
[crea@music music]$ sudo ss -lntp | grep "jellyfin"
LISTEN 0      512          0.0.0.0:8096       0.0.0.0:*    users:(("jellyfi",pid=12910,fd=310))
```
3/ Ouvrir le port derrière lequel Jellyfin écoute
```
[crea@music music]$ sudo firewall-cmd --permanent --add-port=8096/tcp
success
[crea@music music]$ sudo firewall-cmd --reload
success
```
Curl : 
```
<!doctype html>
<html class="preload">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1,minimum-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover">
    <link rel="manifest" href="64d966784cd77b03a79c.json">
    <meta name="format-detection" content="telephone=no">
    <meta name="msapplication-tap-highlight" content="no">
    <meta http-equiv="X-UA-Compatibility" content="IE=Edge">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="application-name" content="Jellyfin">
    <meta name="robots" content="noindex, nofollow, noarchive">
    <meta name="referrer" content="no-referrer">
    <meta property="og:title" content="Jellyfin">
    <meta property="og:site_name" content="Jellyfin">
    <meta property="og:url" content="http://jellyfin.org">
   ```

### Partie III : Serveur de monitoring

1/ Dérouler le script autoconfig.sh développé à la partie I
```
[crea@vbox ~]$ sudo ./autoscript.sh monitoring.tp3.b1
[sudo] password for crea:
Autoscript launched !
Script has root access
SELinux Current mode already on Permissive
SELinux mode from config file already on Permissive
Firewall is active
SSH port changed to 21823 in /etc/ssh/sshd_config
Port 21823/tcp ouvert et port 22 fermé avec succès.
La machine a encore un nom de merde
Nom de machine modifié en backup.tp3.b1
User crea not in wheel group
User crea now in wheel group.
tout a bien marcher :thumbsup:
[crea@vbox ~]$ sudo ss -lntp
State          Recv-Q         Send-Q                 Local Address:Port                   Peer Address:Port         Process
LISTEN         0              128                          0.0.0.0:16677                       0.0.0.0:*             users:(("sshd",pid=1364,fd=3))
LISTEN         0              128                             [::]:16677                          [::]:*             users:(("sshd",pid=1364,fd=4))
```
2/ Installer Netdata
```
curl https://get.netdata.cloud/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --no-updates --stable-channel --disable-telemetry
```
3/ Configuration firewall
```
[crea@monitoring ~]$ sudo systemctl start netdata
[crea@monitoring ~]$ sudo ss -lntp
State    Recv-Q   Send-Q      Local Address:Port        Peer Address:Port   Process
LISTEN   0        4096              0.0.0.0:19999            0.0.0.0:*       users:(("netdata",pid=12899,fd=6))
LISTEN   0        128               0.0.0.0:16677            0.0.0.0:*       users:(("sshd",pid=1364,fd=3))
LISTEN   0        4096            127.0.0.1:8125             0.0.0.0:*       users:(("netdata",pid=12899,fd=53))
LISTEN   0        4096                [::1]:8125                [::]:*       users:(("netdata",pid=12899,fd=52))
LISTEN   0        4096                 [::]:19999               [::]:*       users:(("netdata",pid=12899,fd=7))
LISTEN   0        128                  [::]:16677               [::]:*       users:(("sshd",pid=1364,fd=4))
[crea@monitoring ~]$ sudo firewall-cmd --permanent --add-port=8125/tcp
success
[crea@monitoring ~]$ sudo firewall-cmd --reload
success
```
4/ Check TCP
```
cd /etc/netdata 2>/dev/null || cd /opt/netdata/etc/netdata
sudo ./edit-config go.d/portcheck.conf
```
Conf :
```
jobs
 - name: jellyfin
   host: 10.3.1.11
   ports:
        - 8096
```
5/ Alertes Discord
```
cd /etc/netdata 2>/dev/null || cd /opt/netdata/etc/netdata
sudo ./edit-config health_alarm_notify.conf 
```
Conf : 
```
SEND_DISCORD="YES"
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/1327329025798180975/w7T-wuUERA2CEsNTWhNnxfMQHAFHTvTp7THS5V4GSKSbka2E0MpOUyz3SDhOs90l-0V6"
DEFAULT_RECIPIENT_DISCORD="alerts"
```
**3. Gestion du disque dur**  

1/ Partionner le disque dur
```
[crea@backup ~]$ sudo pvcreate /dev/sdb
[sudo] password for crea:
  Physical volume "/dev/sdb" successfully created.
[crea@backup ~]$ sudo pvs
  PV         VG      Fmt  Attr PSize   PFree
  /dev/sda2  rl_vbox lvm2 a--  <19.00g    0
  /dev/sdb           lvm2 ---    5.00g 5.00g

[crea@backup ~]$ sudo vgcreate data /dev/sdb
  Volume group "data" successfully created
[crea@backup ~]$ sudo vgs
  VG      #PV #LV #SN Attr   VSize   VFree
  data      1   0   0 wz--n-  <5.00g <5.00g
  rl_vbox   1   2   0 wz--n- <19.00g     0

[crea@backup ~]$ sudo lvcreate -L 5000MB data -n backup_data
  Logical volume "backup_data" created.
[crea@backup ~]$ sudo lvs
  LV          VG      Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  backup_data data    -wi-a-----   4.88g

  root        rl_vbox -wi-ao---- <17.00g

  swap        rl_vbox -wi-ao----   2.00g
```
2/ Formater la partition créée
```
[crea@backup ~]$ sudo mkfs -t ext4 /dev/data/backup_data
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 1280000 4k blocks and 320000 inodes
Filesystem UUID: f6b16000-c345-485b-87b2-c5ed38e136e9
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```
3/ Monter la partition
```
[crea@backup ~]$ sudo mkdir /mnt/backup
[crea@backup ~]$ sudo mount /dev/data/backup_data /mnt/backup
[crea@backup ~]$ df -h
Filesystem                    Size  Used Avail Use% Mounted on
devtmpfs                      4.0M     0  4.0M   0% /dev
tmpfs                         888M     0  888M   0% /dev/shm
tmpfs                         355M  5.7M  350M   2% /run
/dev/mapper/rl_vbox-root       17G  1.4G   16G   8% /
/dev/sda1                     960M  230M  731M  24% /boot
tmpfs                         178M     0  178M   0% /run/user/1000
/dev/mapper/data-backup_data  4.8G   24K  4.5G   1% /mnt/backup
```
4/ Configurer un montage automatique de la partition
```
[crea@backup ~]$ nano /etc/fstab
[crea@backup ~]$ sudo nano /etc/fstab (oui vim c'est mieux je sais)
```
Ajout de : ```/dev/data/backup_data /mnt/backup       ext4    defaults        0       0```
dans /etc/fstab
```
[crea@backup ~]$ sudo umount /mnt/backup
[crea@backup ~]$ sudo mount -av
/                        : ignored
/boot                    : already mounted
none                     : ignored
mount: /mnt/backup does not contain SELinux labels.
       You just mounted a file system that supports labels which does not
       contain labels, onto an SELinux box. It is likely that confined
       applications will generate AVC messages and not be allowed access to
       this file system.  For more details see restorecon(8) and mount(8).
mount: (hint) your fstab has been modified, but systemd still uses
       the old version; use 'systemctl daemon-reload' to reload.
/mnt/backup              : successfully mounted
```

**4. Service NFS**  
*A. El servor*  
1/ Installation 
```
sudo dnf install nfs-utils -y
``` 
2/ Export
```
[crea@backup ~]$ sudo nano /etc/exports
```
Ajout de la ligne suivante : 
```
/mnt/backup     10.3.1.11(rw,sync,no_subtree_check)
```
```
[crea@backup ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[crea@backup ~]$ sudo systemctl start nfs-server
[crea@backup ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; p>
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Wed 2025-01-15 08:58:30 CET; 5s ago
```
3/ Configuration Firewall
```
[crea@backup ~]$ sudo firewall-cmd --permanent --add-service=nfs
success
[crea@backup ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[crea@backup ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[crea@backup ~]$ sudo firewall-cmd --reload
success
[crea@backup ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```
4/ Ports NFS
```
[crea@backup ~]$ sudo ss -lntp | grep "rpc"
LISTEN 0      4096         0.0.0.0:48723      0.0.0.0:*    users:(("rpc.statd",pid=11919,fd=8))
LISTEN 0      4096         0.0.0.0:20048      0.0.0.0:*    users:(("rpc.mountd",pid=11923,fd=5))
LISTEN 0      4096         0.0.0.0:111        0.0.0.0:*    users:(("rpcbind",pid=11917,fd=4),("systemd",pid=1,fd=45))
LISTEN 0      4096            [::]:20048         [::]:*    users:(("rpc.mountd",pid=11923,fd=7))
LISTEN 0      4096            [::]:33473         [::]:*    users:(("rpc.statd",pid=11919,fd=10))
LISTEN 0      4096            [::]:111           [::]:*    users:(("rpcbind",pid=11917,fd=6),("systemd",pid=1,fd=47))
LISTEN   0        64                   [::]:2049                [::]:*
```
*B. El cliente*

1/  Installer les outils NFS
```
[crea@music ~]$ sudo dnf install nfs-utils
```
2/ Essayer d'accéder au dossier partagé

```
[crea@music mnt]$ sudo mkdir /mnt/music_backup
[crea@music ~]$ sudo mount 10.3.1.13:/mnt/backup /mnt/music_backup
[crea@music ~]$ cd /mnt/music_backup/
[crea@music music_backup]$ touch test.txt
[crea@music music_backup]$ ls
lost+found  test.txt
[crea@music music_backup]$ echo salut > test.txt
[crea@music music_backup]$ echo salut salut > test.txt
[crea@music music_backup]$ cat test.txt
salut salut
[crea@music music_backup]$ rm -f test.txt
[crea@music music_backup]$ ls
lost+found
```
3/ Configurer un montage automatique
Nouvelle entrée dans /etc/fstab :
```
10.3.1.13:/mnt/backup /mnt/music_backup       nfs     defaults       0	    0
```

**5. Service de backup**  

*A. Script de sauvegarde*
1/ Script backup.sh
Sur music.tp3.b1 : 
```
[crea@music opt]$ ./backup.sh
Script Launched !
tar: Removing leading `/' from member names
/srv/music/
/srv/music/Hollow_Soul.mp3
/srv/music/Legends_Never_Die.mp3
/srv/music/True_Faith.mp3
If you don't have big red text on your screen, everything went well !
```
Sur backup.tp3.b1 : 
```
[crea@backup ~]$ cd /mnt/backup/
[crea@backup backup]$ ls
lost+found  music_250115_100623.tar.gz
[crea@music ~]$ ls /mnt/music_backup/
lost+found  music_250115_100623.tar.gz
```
