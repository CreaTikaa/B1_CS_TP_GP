#/bin/bash
echo "Autoscript launched !"
if [ $(id -u) != 0 ]
  then echo "Script needs to have root access"
  exit
  else 
  echo "Script has root access"
fi

if [ $(sestatus | grep "Current mode" | tr -s ' ' | cut -d ' ' -f3) != "permissive" ];
    then $(setenforce 0) 
    echo "Current mode sucessfuly set on Permissive"
    else 
    echo "SELinux Current mode already on Permissive"
fi
if [ $(sestatus | grep "Mode from config file" | tr -s ' ' | cut -d ' ' -f5) != "permissive" ];
    then $(sed -i 's/enforcing/permissive/g' /etc/selinux/config)
    else 
    echo "SELinux mode from config file already on Permissive"
fi
if [ $(systemctl status firewalld | grep 'Active' | tr -s ' ' | cut -d ' ' -f3) != "active" ];
    then echo "Firewall is inactive" 
    exit
    else echo "Firewall is active"
fi 

random_num=$((RANDOM))
    while [ $random_num -lt 1024 ] || [ $random_num -gt 65535 ]; 
    do
    random_num=$RANDOM
    done

if [ $(ss -lntp | grep '22' | cut -d '(' -f3 | cut -d '"' -f2 |
head -n 1) = "sshd" ];
then 
    $(sed -i "s/#Port 22/Port ${random_num}/g" /etc/ssh/sshd_config)
    systemctl restart sshd
    firewall-cmd --permanent --add-port=${random_num}/tcp > /dev/null 2>&1
    firewall-cmd --permanent --remove-port=22/tcp > /dev/null 2>&1
    firewall-cmd --reload > /dev/null 2>&1
    echo "SSH port changed to ${random_num} in /etc/ssh/sshd_config"
    echo "Port ${random_num}/tcp ouvert et port 22 fermé avec succès."
else 
    echo "gg le port ssh cest deja un autre que 22"
fi 

if [ "$(hostname)" = "localhost" ] || [ "$(hostname)" = "vbox" ]; 
then
echo "La machine a encore un nom de merde"
    if [ -z "$1" ]; 
    then
        echo "Faut mettre le nom de la machine la en gros"
        exit
    else
        hostnamectl set-hostname "$1"
        echo "Nom de machine modifié en $(hostname)"
    fi
else
    echo "Ton nom de machine est $(hostname)"
fi


if ! getent group wheel | grep -q "$(whoami)";
then 
    echo "User ${whoami} not in wheel group"
    usermod -aG wheel $(whoami)
    echo "User ${whoami} now in wheel group."
else
    echo "c bon t dans le grp wheel bro"
fi 

echo "tout a bien marcher :thumbsup:"
