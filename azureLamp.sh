echo Deleting old Azure resource group...
az account set --subscription 'Azure for Students'
if [ "$(az group exists --name myResourceGroup)" = "true" ]; then 
  az group delete --name myResourceGroup --yes --no-wait; 
  echo Waiting for Azure Resource Group to be deleted...
  az group wait --deleted --name myResourceGroup;
fi

echo Creating a new resource group and VM...
az group create \
  --name myResourceGroup \
  --location northeurope \
  --subscription 'Azure for Students' &&
az vm create \
  --resource-group myResourceGroup \
  --name myVM \
  --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts:latest \
  --size Standard_B1s \
  --os-disk-size-gb 64 \
  --public-ip-sku Basic \
  --authentication-type all \
  --generate-ssh-keys \
  --admin-username azureuser \
  --admin-password login2VM1234 &&
az vm wait --created -g myResourceGroup -n myVM
az vm open-port \
  --resource-group myResourceGroup \
  --name myVM \
  --port 80,443,3389 &&
ssh -t -oStrictHostKeyChecking=no azureuser@$(az vm show -d -g myResourceGroup -n myVM --query publicIps -o tsv)      \
'\
echo Install LAMP &&
sudo apt update -qq && sudo apt install -f apache2 mysql-server php -y &&
sudo sed -i.bak -e "s/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g" /etc/apache2/mods-enabled/dir.conf &&
sudo touch /var/www/html/info.php;sudo chmod 666 /var/www/html/info.php;sudo echo "<?php phpinfo(); ?>" > /var/www/html/info.php &&
printf "\nOpen an internet browser (e.g. Chrome) and go to \e[3;4;33mhttp://$(dig +short myip.opendns.com @resolver1.opendns.com)\e[0m - You should see the Apache default page.\n"
printf "\nOpen an internet browser (e.g. Chrome) and go to \e[3;4;33mhttp://$(dig +short myip.opendns.com @resolver1.opendns.com)/info.php\e[0m - You should see a PHP info page.\n"

echo Installing Adminer &&
sudo apt -y install adminer && 
sudo a2enconf adminer && 
sudo systemctl reload apache2 &&
sudo mysql -Bse "CREATE USER IF NOT EXISTS admin@localhost IDENTIFIED BY \"password\";GRANT ALL PRIVILEGES ON *.* TO admin@localhost;FLUSH PRIVILEGES;" &&
printf "\nOpen an internet browser (e.g. Chrome) and go to \e[3;4;33mhttp://$(dig +short myip.opendns.com @resolver1.opendns.com)/adminer/?username=admin\e[0m - You should see the Adminer Login page. Username is admin and password is password. Leave Database empty.\n"

echo install phpmyadmin &&
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" # Select Web Server &&
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true" # Configure database for phpmyadmin with dbconfig-common &&
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password 'password'" # Set MySQL application password for phpmyadmin &&
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password 'password'" # Confirm application password &&
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/internal/skip-preseed boolean true" &&
DEBIAN_FRONTEND=noninteractive sudo apt -qy install phpmyadmin &&
printf "\nOpen an internet browser (e.g. Chrome) and go to \e[3;4;33mhttp://$(dig +short myip.opendns.com @resolver1.opendns.com)/phpmyadmin\e[0m - You should see the phpMyAdmin login page. admin/password\n"

echo Enable root login for SFTP
sudo sed -i "/PermitRootLogin/c\PermitRootLogin yes" /etc/ssh/sshd_config &&
sudo echo -e "login2VM1234\nlogin2VM1234" | sudo passwd root &&
sudo service sshd restart
printf "\nOpen an internet browser (e.g. Edge) and go to \e[3;4;33mhttps://tinyurl.com/47k4bwcr\e[0m - This will download WinSCP. Connect yo your VM with Hostname/ User/ Password = $(dig +short myip.opendns.com @resolver1.opendns.com) / root / login2VM1234.\n" &&
printf "\nOpen an internet browser (e.g. Chrome) and go to \e[3;4;33mhttp://$(dig +short myip.opendns.com @resolver1.opendns.com)\e[0m - You should see a simple index.php webpage.\n"
echo Staying logged into this new VM
bash -l
'
