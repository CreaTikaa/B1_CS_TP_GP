# TP 1 - Gestion de parc

### I. Service SSH
**1. Analyse du service**  

1/ S'assurer que le service sshd est démarré
```
[crea@web ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; preset: enabled)
     Active: active (running) since Fri 2024-11-29 16:38:34 CET; 30min ago
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 704 (sshd)
      Tasks: 1 (limit: 11084)
     Memory: 4.9M
        CPU: 125ms
     CGroup: /system.slice/sshd.service
             └─704 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
```
2/ Analyser les processus liés au service SSH
```
[crea@web ~]$ ps -ef | grep sshd
root         704       1  0 16:38 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        1455     704  0 17:04 ?        00:00:00 sshd: crea [priv]
crea        1459    1455  0 17:04 ?        00:00:00 sshd: crea@pts/0
```
3/ Déterminer le port sur lequel écoute le service SSH
```
[crea@web ~]$ ss | grep ssh
tcp   ESTAB  0      52                         10.1.1.1:ssh           10.1.1.3:22593
```
4/ Consulter les logs du service SSH
```
[crea@web ~]$ journalctl /usr/sbin/sshd
Nov 29 16:38:34 localhost.localdomain sshd[704]: Server listening on 0.0.0.0 port 22.
Nov 29 16:38:34 localhost.localdomain sshd[704]: Server listening on :: port 22.
Nov 29 16:44:26 web.tp1.b1 sshd[1305]: Accepted password for crea from 192.168.56.1 port 50165 ssh2
Nov 29 16:44:26 web.tp1.b1 sshd[1305]: pam_unix(sshd:session): session opened for user crea(uid=1000) by crea(u>
Nov 29 17:04:01 web.tp1.b1 sshd[1305]: pam_unix(sshd:session): session closed for user crea
Nov 29 17:04:27 web.tp1.b1 sshd[1455]: Accepted password for crea from 10.1.1.3 port 22593 ssh2
Nov 29 17:04:27 web.tp1.b1 sshd[1455]: pam_unix(sshd:session): session opened for user crea(uid=1000) by crea(u>
```
&
```
[crea@web log]$ sudo tail -n 5 /var/log/secure
Nov 29 17:17:10 vbox sudo[1535]: pam_unix(sudo:session): session opened for user root(uid=0) by crea(uid=1000)
Nov 29 17:17:10 vbox sudo[1535]: pam_unix(sudo:session): session closed for user root
Nov 29 17:17:43 vbox sudo[1541]:    crea : TTY=pts/0 ; PWD=/var/log ; USER=root ; COMMAND=/bin/tail -n 50 /var/log/secure
Nov 29 17:17:43 vbox sudo[1541]: pam_unix(sudo:session): session opened for user root(uid=0) by crea(uid=1000)
Nov 29 17:17:43 vbox sudo[1541]: pam_unix(sudo:session): session closed for user root
```
**2. Modification du service**  
1/ Identifier le fichier de configuration du serveur SSH
Client :
```
[crea@web ssh]$ ls | grep "ssh_config"
ssh_config
ssh_config.d
```
Daemon : 
```
[crea@web ssh]$ ls | grep "sshd_config"
sshd_config
sshd_config.d
```
2/ Modifier le fichier de conf
```
[crea@web ssh]$ echo $RANDOM
13176
[crea@web ssh]$ sudo cat sshd_config | grep "13176"
Port 13176
``` 
Firewall :
```
[crea@web ~]$ sudo firewall-cmd --permanent --remove-port=22/tcp
Warning: NOT_ENABLED: 22:tcp
success
[crea@web ~]$ sudo firewall-cmd --permanent --add-port=13176/tcp
success
[crea@web ~]$ sudo firewall-cmd --reload
success
[crea@web ~]$ sudo firewall-cmd --list-all | grep 13176
  ports: 13176/tcp
```
3/ Redémarrer le service
```
[crea@web ~]$ sudo systemctl restart sshd
```
4/ Reconnexion
```
PS C:\Users\creat> ssh crea@10.1.1.1 -p 13176
crea@10.1.1.1's password:
Last login: Fri Nov 29 17:04:27 2024 from 10.1.1.3
[crea@web ~]$
```
5/ Bonus
```
PermitEmptyPasswords no
PermitRootLogin no
AllowUsers crea
PasswordAuthentication no
PublicKeyAuthentication yes
```
### II. Service HTTP

**1. Mise en place**  
1/ Install nginx
```
[crea@web ~]$ dnf search nginx
Rocky Linux 9 - BaseOS                                                          2.5 MB/s | 2.3 MB     00:00
Rocky Linux 9 - AppStream                                                       4.3 MB/s | 8.3 MB     00:01
Rocky Linux 9 - Extras                                                           35 kB/s |  16 kB     00:00
========================================= Name Exactly Matched: nginx ==========================================nginx.x86_64 : A high performance web server and reverse proxy server
[crea@web ~]$ sudo dnf install nginx.x86_64
[sudo] password for crea:
Last metadata expiration check: 0:07:40 ago on Fri 29 Nov 2024 05:31:16 PM CET.
Dependencies resolved.
================================================================================================================
 Package                       Architecture       Version                           Repository             Size
================================================================================================================
Installing:
 nginx                         x86_64             2:1.20.1-20.el9.0.1               appstream              36 k
```
2/ Start NGINX
```
[crea@web ~]$ sudo systemctl start nginx
```
3/ Déterminer sur quel port tourne NGINX
```
[crea@web ~]$ sudo firewall-cmd --permanent --add-service=http
success
[crea@web ~]$ sudo firewall-cmd --permanent --add-port=80/tcp 
sudo firewall-cmd --reload
success
success
[crea@web ~]$  sudo firewall-cmd --permanent --list-all | grep "80"
  ports: 13176/tcp 80/tcp
[crea@web ~]$ sudo ss -lntp | grep "80"
LISTEN 0      511          0.0.0.0:80         0.0.0.0:*    users:(("nginx",pid=1874,fd=6),("nginx",pid=1873,fd=6))
LISTEN 0      511             [::]:80            [::]:*    users:(("nginx",pid=1874,fd=7),("nginx",pid=1873,fd=7))
```
4/ Déterminer les processus liés au service NGINX
```
[crea@web ~]$ ps -ef | grep "nginx"
root        1833       1  0 17:42 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1834    1833  0 17:42 ?        00:00:00 nginx: worker process
```
5/ Déterminer le nom de l'utilisateur qui lance NGINX
```
[crea@web ~]$ cat /etc/passwd | grep "nginx"
nginx:x:996:993:Nginx web server:/var/lib/nginx:/sbin/nologin
```
6/ Test !
```
crea@crea MINGW64 ~
$ curl http://10.1.1.1:80 | head
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
      /*<![CDATA[*/

      html {
```
**2. Analyser la conf de NGINX** 
1/ Déterminer le path du fichier de configuration de NGINX
```
[crea@web ~]$ sudo find / -name "nginx"
/etc/logrotate.d/nginx
/etc/nginx
/var/lib/nginx
/var/log/nginx
/usr/sbin/nginx
/usr/lib64/nginx
/usr/share/nginx
->
[crea@web ~]$ ls -al /etc/nginx
total 84
drwxr-xr-x.  4 root root 4096 Nov 29 17:39 .
drwxr-xr-x. 82 root root 8192 Nov 29 17:39 ..
drwxr-xr-x.  2 root root    6 Nov  8 17:44 conf.d
drwxr-xr-x.  2 root root    6 Nov  8 17:44 default.d
-rw-r--r--.  1 root root 1077 Nov  8 17:44 fastcgi.conf
-rw-r--r--.  1 root root 1077 Nov  8 17:44 fastcgi.conf.default
-rw-r--r--.  1 root root 1007 Nov  8 17:44 fastcgi_params
-rw-r--r--.  1 root root 1007 Nov  8 17:44 fastcgi_params.default
-rw-r--r--.  1 root root 2837 Nov  8 17:44 koi-utf
-rw-r--r--.  1 root root 2223 Nov  8 17:44 koi-win
-rw-r--r--.  1 root root 5231 Nov  8 17:44 mime.types
-rw-r--r--.  1 root root 5231 Nov  8 17:44 mime.types.default
-rw-r--r--.  1 root root 2334 Nov  8 17:43 nginx.conf
-rw-r--r--.  1 root root 2656 Nov  8 17:44 nginx.conf.default
-rw-r--r--.  1 root root  636 Nov  8 17:44 scgi_params
-rw-r--r--.  1 root root  636 Nov  8 17:44 scgi_params.default
-rw-r--r--.  1 root root  664 Nov  8 17:44 uwsgi_params
-rw-r--r--.  1 root root  664 Nov  8 17:44 uwsgi_params.default
-rw-r--r--.  1 root root 3610 Nov  8 17:44 win-utf
```
2/ Trouver dans le fichier de conf
```
[crea@web nginx]$ cat /etc/nginx/nginx.conf | grep "server" -A 10
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
--
# Settings for a TLS enabled server.
#
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {
#        }
#
#        error_page 500 502 503 504 /50x.html;
#            location = /50x.html {
#        }
#    }
```
Include : 
```
[crea@web nginx]$ cat /etc/nginx/nginx.conf | grep "include"
include /usr/share/nginx/modules/*.conf;
    include             /etc/nginx/mime.types;
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/default.d/*.conf;
#        include /etc/nginx/default.d/*.conf;
```
user : 
```
[crea@web nginx]$ cat /etc/nginx/nginx.conf | grep "user"
user nginx;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
```
**3. Déployer un nouveau site web**  
1/ Créer un site web
```
[crea@web www]$ pwd
/var/www
[crea@web www]$ mkdir tp1_parc
mkdir: cannot create directory ‘tp1_parc’: Permission denied
[crea@web www]$ pwd
/var/www
[crea@web www]$ sudo mkdir tp1_parc
[crea@web tp1_parc]$ sudo nano index.html
```
2/ Gérer les permissions
```
[crea@web tp1_parc]$ sudo chown nginx:nginx /var/www/tp1_parc/*
[crea@web tp1_parc]$ ls -l
total 4
-rw-r--r--. 1 nginx nginx 38 Nov 29 18:27 index.html
```
3/ Adapter la conf NGINX
```
[crea@web ~]$ echo $RANDOM
1907
[crea@web conf.d]$ pwd
/etc/nginx/conf.d
[crea@web conf.d]$ sudo nano nginx_my_conf.conf
[crea@web nginx]$ sudo firewall-cmd --permanent --add-port=1907/tcp
sudo firewall-cmd --reload
[crea@web nginx]$ sudo systemctl restart nginx
```
Curl : 
```
crea@crea MINGW64 ~
$ curl http://10.1.1.1:1907 | head
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    38  100    38    0     0   1587      0 --:--:-- --:--:-- --:--:--  1652<h1>MEOW mon premier serveur web</h1>
```
### III. Monitoring et alerting

**1. Installation**  
1/ Installer Netdata
```
curl https://get.netdata.cloud/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --no-updates --stable-channel --disable-telemetry
```

**2. Un peu d'analyse de service**
1/ Démarrer le service netdata
```
[crea@monitoring ~]$ sudo systemctl start netdata
[crea@monitoring ~]$ sudo systemctl status netdata
● netdata.service - Real time performance monitoring
     Loaded: loaded (/usr/lib/systemd/system/netdata.service; enabled; preset: enabled)
     Active: active (running) since Mon 2024-12-02 14:23:02 CET; 52s ago
```
2/ Déterminer sur quel port tourne Netdata
```
[crea@monitoring ~]$ sudo ss -lntp | grep "netdata"
LISTEN 0      4096       127.0.0.1:8125       0.0.0.0:*    users:(("netdata",pid=2938,fd=43))
LISTEN 0      4096         0.0.0.0:19999      0.0.0.0:*    users:(("netdata",pid=2938,fd=6))
LISTEN 0      4096           [::1]:8125          [::]:*    users:(("netdata",pid=2938,fd=39))
LISTEN 0      4096            [::]:19999         [::]:*    users:(("netdata",pid=2938,fd=7))
```
Ouvrir le port : 
```
[crea@monitoring ~]$ sudo firewall-cmd --permanent --add-port=19999/tcp
sudo firewall-cmd --reload
success
success
```
3/ Visiter l'interface Web
```
crea@crea MINGW64 ~
$ curl http://10.1.1.2:19999/ | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!doctype html><html lang="en" dir="ltr"><head><meta charset="utf-8"/><title>Netdata</title><script>const CONFIG = {
      cache: {
        agentInfo: false,
        cloudToken: true,
        agentToken: true,
      }
    }
  6  106k    6  6929    0     0   196k      0 --:--:-- --:--:-- --:--:--  199k
```
**3. Ajouter un check** 
sur web.tp1.b1 :  
```
[crea@web ~]$ sudo systemctl start nginx
[crea@web ~]$ sudo ss -lntp | grep nginx
LISTEN 0      511          0.0.0.0:1907       0.0.0.0:*    users:(("nginx",pid=1311,fd=6),("nginx",pid=1310,fd=6))
```
Conf:
```
[crea@monitoring netdata]$ sudo ./edit-config go.d/portcheck.conf
Editing '/etc/netdata/go.d/portcheck.conf' …
[crea@monitoring netdata]$ sudo systemctl restart netdata
[crea@monitoring netdata]$ cat /etc/netdata//go.d/portcheck.conf | grep WEB_web.tp1.b1 -A 4
  - name: WEB_web.tp1.b1
    host: 10.1.1.1
    ports:
      - 1907
```
Conf finale : 
```
      - 1907

  - name: SSH_web.tp1.b1
    host: 10.1.1.1
    ports:
      - 22
```
**4. Ajouter des alertes**  
1/ Configurer l'alerting avec Discord
```
# enable/disable sending discord notifications
SEND_DISCORD="YES"

# Create a webhook by following the official documentation -
# https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/1313151237184688158/tC-t1fgyPdGQKp_L_6BE7hr_5LVtpQRPa_q70xq4CqVWPTI7nzv2pO4f4TbnA2lWRlE5"

# if a role's recipients are not configured, a notification will be send to
# this discord channel (empty = do not send a notification for unconfigured
# roles):
DEFAULT_RECIPIENT_DISCORD="alerts"
```
2/ Test : 
```
RECEIVED HTTP RESPONSE CODE: 200
time=2024-12-02T15:56:11.416+01:00 comm=alarm-notify.sh source=health level=info tid=14702 thread=alarm-notify msg_id=6db0018e83e34320ae2a659d78019fb7 node=monitoring.tp1.b1 instance=test.chart alert_id=1 alert_unique_id=1 alert=test_alarm alert_class=Test alert_recipient=alerts alert_duration=1 alert_value=100 alert_value_old=90 alert_status=CLEAR alert_value_old=CRITICAL alert_units=units alert_summary="a test alarm" alert_info="this is a test alarm to verify notifications work" request="'/usr/libexec/netdata/plugins.d/alarm-notify.sh' 'alerts' 'monitoring.tp1.b1' '1' '1' '3' '1733151370' 'test_alarm' 'test.chart' 'CLEAR' 'CRITICAL' '100' '90' '/usr/libexec/netdata/plugins.d/alarm-notify.sh' '1' '3' 'units' 'this is a test alarm to verify notifications work' 'new value' 'old value' 'evaluated expression' 'expression variable values' '0' '0' '' '' 'Test' 'command to edit the alarm=0=monitoring.tp1.b1' '' '' 'a test alarm' " msg="[ALERT NOTIFICATION]: sent discord notification to 'alerts' for notification to 'alerts' for transition from CRITICAL to CLEAR, of alert 'test_alarm' = 'new value', of instance 'test.chart', context '' on host 'monitoring.tp1.b1'"
# OK
```
3/ Alerte si le site est down : 
```
template: web_server_down
      on: portcheck.WEB_web.tp1.b1
    lookup: average -10s unaligned of availability
     every: 5s
      warn: $this < 1
      crit: $this < 1
     delay: down 5s
    repeat: every 5s
     units: %
      info: Web server is down
       to: admin
```
(valeurs si basses juste pour test)  

**4/ Le reste : Voir sur Discord (invite envoyé en DM)**


