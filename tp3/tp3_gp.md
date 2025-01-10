# TP 3

**1. Préparation de la machine**
```
[crea@music ~]$ cd /srv
[crea@music srv]$ sudo mkdir music
[sudo] password for crea:
[crea@music srv]$ ls
music
```
2/
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
TODO:  CURL

### Partie III : Serveur de monitoring

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
3/
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

