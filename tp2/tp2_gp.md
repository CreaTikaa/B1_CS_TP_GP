# TP2 : Du shell, des scripts et serviiiice

### Partie I : Des beaux one-liners

**2. Let's go**  
1/  Afficher la quantité d'espace disque disponible
```
[crea@node1 ~]$ df -h | grep "vbox-root" | tr -s ' ' | cut -d' ' -f4
16G
```
2/ Afficher l'heure et la date
```
[crea@node1 ~]$ echo $(date '+%d-%m-%Y %T')
09-12-2024 15:45:01
```
3/ Afficher la version de l'OS précise
```
[crea@node1 ~]$ source /etc/os-release && echo "$PRETTY_NAME" | cut -d ' ' -f1-3
Rocky Linux 9.5
```
4/ Afficher la version du kernel en cours d'utilisation précise
```
[crea@node1 ~]$ uname -a | tr -s ' ' | cut -d ' ' -f3
5.14.0-503.14.1.el9_5.x86_64
```
5/ Afficher le chemin vers la commande python3
```
[crea@node1 ~]$ which python
/usr/bin/python
```
6/ Afficher l'utilisateur actuellement connecté
```
[crea@node1 ~]$ echo $USER
crea
```
7/ Afficher le shell par défaut de votre utilisateur actuellement connecté
```
[crea@node1 ~]$ cat /etc/passwd | grep $USER | cut -d ':' -f7
/bin/bash
```
8/ Afficher le nombre de paquets installés
```
[crea@node1 ~]$ rpm -qa | wc -l
359
```
/9 Afficher le nombre de ports en écoute
```
[crea@node1 ~]$ ss -lntpu | grep 'LISTEN' | cut -d ':' -f2 | cut -d ' ' -f1 | head -1
22
```

### Partie II : Un premier ptit script  
**2. Premiers pas scripting**   
1/ Ecrire un script qui produit exactement l'affichage demandé
```bash
#!/bin/bash
#Script qui permet d'afficher des informations importantes

whouser=$(echo $USER)
date=$(echo $(date '+%d-%m-%Y %T'))
shell=$(cat /etc/passwd | grep $USER | cut -d ':' -f7)
os_ver=$(source /etc/os-release && echo "$PRETTY_NAME" | cut -d ' ' -f1-3)
kernel_ver=$(uname -a | tr -s ' ' | cut -d ' ' -f3)
ram_free=$(free -mh | grep 'Mem:' | tr -s ' ' | cut -d' ' -f7)
disk_free=$(df -h | grep "vbox-root" | tr -s ' ' | cut -d' ' -f4)
inodes_free=$(df -i | grep "vbox-root" | tr -s ' ' | cut -d ' ' -f4
8877501)
paquets_installes=$(rpm -qa | wc -l)
open_ports=$(ss -lntpu | awk '{print $5}' | grep -o '[0-9]\+$' | uniq | wc -l)
python_path=$(which python)


echo "Salu a toa $whouser."
echo "Nouvelle connexion $date".
echo "Connecté avec le shell $shell".
echo "OS : $os_ver - Kernel : $kernel_ver"
echo "Ressources :"
echo "- $ram_free RAM dispo"
echo "- $disk_free espace disque dispo"
echo "- $inodes_free fichiers restants"
echo "Actuellement : "
echo "- $paquets_installes paquets installés"
echo "- $open_ports port(s) ouvert(s)"
echo "Python est bien installé sur la machine au chemin : $python_path"
```
**3. Amélioration du script**    
1/ Le script id.sh affiche l'état du firewall
Ajout de : 
```
firewall=$(systemctl is-active firewalld)
if [[ $firewall -eq "active" ]]
then
  echo "Le firewall est actif."
else
  echo "Le firewall est inactif."
fi
```
2/  Le script id.sh affiche l'URL vers une photo de chat random
```
cat_pic=$(curl https://api.thecatapi.com/v1/images/search | tr -s '"' | cut -d '"' -f8)
echo "Voila ta photo de chat : $cat_pic"
```
**4. Bannière**   
```
[crea@node1 ~]$ sudo mv /home/crea/id.sh /opt
[crea@node1 ~]$ ls -al /opt
total 4
drwxr-xr-x.  2 root root   19 Dec  9 17:25 .
dr-xr-xr-x. 18 root root  235 Nov 29 16:02 ..
-rwxr-xr-x.  1 crea crea 1401 Dec  9 17:15 id.sh
```
Directement après la connexion :   
```
PS C:\Users\creat> ssh crea@10.2.1.1
crea@10.2.1.1's password:
Last login: Mon Dec  9 16:21:12 2024 from 10.2.1.3
Salu a toa crea.
Nouvelle connexion 09-12-2024 17:29:17.
Connecté avec le shell /bin/bash.
OS : Rocky Linux 9.5 - Kernel : 5.14.0-503.14.1.el9_5.x86_64
Ressources :
- 1.2Gi RAM dispo
- 16G espace disque dispo
- 8875475 fichiers restants
Actuellement :
- 360 paquets installés
- 3 port(s) ouvert(s)
Python est bien installé sur la machine au chemin : /usr/bin/python
Le firewall est actif.
Voila ta photo de chat : https://cdn2.thecatapi.com/images/c0p.jpg
```
**5. Bonus : des paillettes**    
c'est ignoble (vraiment super moche)
```
#!/bin/bash
# Script qui permet d'afficher des informations importantes

RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
NC="\e[0m" 

whouser=$(echo $USER)
date=$(echo $(date '+%d-%m-%Y %T'))
shell=$(cat /etc/passwd | grep $USER | cut -d ':' -f7)
os_ver=$(source /etc/os-release && echo "$PRETTY_NAME" | cut -d ' ' -f1-3)
kernel_ver=$(uname -a | tr -s ' ' | cut -d ' ' -f3)
ram_free=$(free -mh | grep 'Mem:' | tr -s ' ' | cut -d' ' -f7)
disk_free=$(df -h | grep "vbox-root" | tr -s ' ' | cut -d' ' -f4)
inodes_free=$(df -i | grep "vbox-root" | tr -s ' ' | cut -d ' ' -f4)
paquets_installes=$(rpm -qa | wc -l)
open_ports=$(ss -lntpu | awk '{print $5}' | grep -o '[0-9]\+$' | uniq | wc -l)
python_path=$(which python)
firewall=$(systemctl is-active firewalld)
cat_pic=$(curl -s https://api.thecatapi.com/v1/images/search | tr -s '"' | cut -d '"' -f8)

echo -e "${BLUE}Salu a toa $whouser.${NC}"
echo -e "${YELLOW}Nouvelle connexion $date.${NC}"
echo -e "${GREEN}Connecté avec le shell $shell.${NC}"
echo -e "${RED}OS : $os_ver - Kernel : $kernel_ver${NC}"
echo -e "${YELLOW}Ressources :${NC}"
echo -e "  - ${GREEN}$ram_free${NC} RAM dispo"
echo -e "  - ${GREEN}$disk_free${NC} espace disque dispo"
echo -e "  - ${GREEN}$inodes_free${NC} fichiers restants"
echo -e "${YELLOW}Actuellement : ${NC}"
echo -e "  - ${GREEN}$paquets_installes${NC} paquets installés"
echo -e "  - ${GREEN}$open_ports${NC} port(s) ouvert(s)"
echo -e "Python est bien installé sur la machine au chemin : ${GREEN}$python_path${NC}"

if [[ $firewall == "active" ]]; then
  echo -e "${GREEN}Le firewall est actif.${NC}"
else
  echo -e "${RED}Le firewall est inactif.${NC}"
fi

echo -e "${BLUE}Voila ta photo de chat : $cat_pic${NC}"
```

### Partie III : Script youtube-dl  
1/ 
```
[crea@node1 downloads]$ pwd
/opt/yt/downloads
```
2/
```
[crea@node1 yt]$ pwd
/var/log/yt
```
3/
```
[crea@node1 yt]$ yt.sh https://www.youtube.com/watch?v=sNx57atloH8
Video : https://www.youtube.com/watch?v=sNx57atloH8 was downloaded
File Path : /opt/yt/downloads/tomato anxiety/tomato anxiety.mp4
[crea@node1 yt]$ pwd
/var/log/yt
[crea@node1 yt]$ cat download.log
[24-12-16 16:22:23] Video https://www.youtube.com/watch?v=sNx57atloH8 was downloaded. File path : /opt/yt/downloads/tomato anxiety/tomato anxiety.mp4
```

**2. MAKE IT A SERVICE**  
1/ Créer et gérer les permissions de yt
```
[crea@node1 system]$ sudo useradd yt
[crea@node1 system]$ sudo passwd yt
Changing password for user yt.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.
[crea@node1 system]$ sudo usermod -s /sbin/nologin yt
[crea@node1 system]$ sudo chown yt:yt /opt/yt/*
[crea@node1 system]$ sudo chown yt:yt /var/log/yt/*
```











