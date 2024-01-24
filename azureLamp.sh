#!/bin/bash


# Initialize a variable to store the flag value
l_flag='false'

# Use getopts to parse the flag
while getopts 'l' flag; do
  case "$flag" in
    l) l_flag='true' ;; # Set the variable to true if -l is supplied
    *) echo "Usage: $0 [-l]" # Print usage message for invalid flag
       exit 1 ;;
  esac
done

if [ "$l_flag" = "true" ]; then
  echo Installing LAMP... &&
fi




echo Deleting old Azure resource group...
az account set --subscription 'Azure for Students'
if [ "$(az group exists --name LAMPResourceGroupAuto)" = "true" ]; then 
  echo Waiting for old Azure Resource Group to be deleted...
  az group delete --name LAMPResourceGroupAuto --yes; 
  echo Old resource group has been deleted.
fi

echo Creating a new resource group called...
az group create \
  --name LAMPResourceGroupAuto \
  --location northeurope \
  --subscription 'Azure for Students' \
  --query 'name' -o tsv &&
echo Creating a new VM...
az vm create \
  --resource-group LAMPResourceGroupAuto \
  --name LAMPServerAuto \
  --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest \
  --size Standard_B1s \
  --os-disk-size-gb 64 \
  --public-ip-sku Standard \
  --authentication-type all \
  --generate-ssh-keys \
  --admin-username azureuser \
  --admin-password login2VM1234 \
  --security-type TrustedLaunch &&
echo New VM has been created...

echo Opening required ports on new VM...
az vm open-port \
  --resource-group LAMPResourceGroupAuto \
  --name LAMPServerAuto \
  --port 80,443,3389 > /dev/null 2>&1
  
echo SSHing into new VM with IP $(az vm show -d -g LAMPResourceGroupAuto -n LAMPServerAuto --query publicIps -o tsv) ...
ssh -t -oStrictHostKeyChecking=no azureuser@$(az vm show -d -g LAMPResourceGroupAuto -n LAMPServerAuto --query publicIps -o tsv)      \
'\
echo Installing LAMP... &&
sudo apt update -qq -y && sudo apt install apache2 mysql-server php -qq -f -y &&
echo Configuring LAMP... &&
sudo sed -i.bak -e "s/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g" /etc/apache2/mods-enabled/dir.conf &&
sudo touch /var/www/html/info.php;sudo chmod 666 /var/www/html/info.php;sudo echo "<?php phpinfo(); ?>" > /var/www/html/info.php

echo Installing Adminer silently... &&
sudo DEBIAN_FRONTEND=noninteractive apt-get install -qq -y adminer &&
echo Configuring Andminer &&
sudo a2enconf adminer && 
sudo systemctl reload apache2 &&
sudo mysql -Bse "CREATE USER IF NOT EXISTS admin@localhost IDENTIFIED BY \"password\";GRANT ALL PRIVILEGES ON *.* TO admin@localhost;FLUSH PRIVILEGES;"

echo Install phpmyadmin silently... &&
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" # Select Web Server &&
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true" # Configure database for phpmyadmin with dbconfig-common &&
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password 'password'" # Set MySQL application password for phpmyadmin &&
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password 'password'" # Confirm application password &&
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/internal/skip-preseed boolean true" &&
sudo DEBIAN_FRONTEND=noninteractive apt install phpmyadmin -qq -y &&

echo Enabling root login for SFTP...
sudo sed -i "/PermitRootLogin/c\PermitRootLogin yes" /etc/ssh/sshd_config &&
sudo echo -e "login2VM1234\nlogin2VM1234" | sudo passwd root &&
sudo service sshd restart

printf "\nOpen an internet browser (e.g. Chrome) and go to \e[3;4;33mhttp://$(dig +short myip.opendns.com @resolver1.opendns.com)\e[0m - You should see the Apache default page.\n"
printf "\nOpen an internet browser (e.g. Chrome) and go to \e[3;4;33mhttp://$(dig +short myip.opendns.com @resolver1.opendns.com)/info.php\e[0m - You should see a PHP info page.\n"
printf "\nOpen an internet browser (e.g. Chrome) and go to \e[3;4;33mhttp://$(dig +short myip.opendns.com @resolver1.opendns.com)/adminer/?username=admin\e[0m - You should see the Adminer Login page. Username is admin and password is password. Leave Database empty.\n"
printf "\nOpen an internet browser (e.g. Chrome) and go to \e[3;4;33mhttp://$(dig +short myip.opendns.com @resolver1.opendns.com)/phpmyadmin\e[0m - You should see the phpMyAdmin login page. admin/password\n"
printf "\nOpen an internet browser (e.g. Edge) and go to \e[3;4;33mhttps://tinyurl.com/47k4bwcr\e[0m - This will download WinSCP. Connect to your VM --> Hostname = $(dig +short myip.opendns.com @resolver1.opendns.com), User = root, Password = login2VM1234.\n"
echo Staying logged into this new VM
bash -l
'
