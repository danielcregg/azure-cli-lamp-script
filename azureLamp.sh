#!/bin/bash

###########################################
# Azure LAMP Stack Deployment Script
#
# This script automates the deployment of a LAMP stack
# on an Azure VM via Azure Cloud Shell.
#
# It will:
# - Delete any existing resource group
# - Create a new VM with Ubuntu 22.04
# - Install Apache, MySQL, PHP
# - Enable root SFTP access
# - Install VS Code CLI for tunnel access
###########################################

###########################################
# Configuration Variables
###########################################
RESOURCE_GROUP="LAMPResourceGroupAuto"
VM_NAME="LAMPServerAuto"
LOCATION="northeurope"
SUBSCRIPTION="Azure for Students"
VM_SIZE="Standard_B2s"
VM_IMAGE="Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest"
ADMIN_USER="azureuser"
ADMIN_PASSWORD="login2VM1234"

###########################################
# Cleanup Phase
###########################################
echo "Deleting old Azure resource group..."
az account set --subscription "$SUBSCRIPTION"

if [ "$(az group exists --name "$RESOURCE_GROUP")" = "true" ]; then
    echo "Waiting for old Azure Resource Group to be deleted..."
    az group delete --name "$RESOURCE_GROUP" --yes
    echo "Old resource group has been deleted."
fi

###########################################
# Resource Creation Phase
###########################################
echo "Creating a new resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --subscription "$SUBSCRIPTION" \
    --query 'name' -o tsv &&
echo "Creating a new VM..."
az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --image "$VM_IMAGE" \
    --size "$VM_SIZE" \
    --os-disk-size-gb 64 \
    --public-ip-sku Standard \
    --authentication-type all \
    --generate-ssh-keys \
    --admin-username "$ADMIN_USER" \
    --admin-password "$ADMIN_PASSWORD" \
    --security-type TrustedLaunch &&
echo "New VM has been created."

echo "Opening required ports on new VM..."
az vm open-port \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --port 80,443,3389 > /dev/null 2>&1

###########################################
# SSH and Installation Phase
###########################################
VM_IP=$(az vm show -d -g "$RESOURCE_GROUP" -n "$VM_NAME" --query publicIps -o tsv)
echo "SSHing into new VM with IP ${VM_IP}"

ssh -t -o StrictHostKeyChecking=no "${ADMIN_USER}@${VM_IP}" '
echo "Installing LAMP..." &&
sudo apt update -qq -y && sudo apt install apache2 mysql-server php -qq -f -y &&

echo "Configuring LAMP..." &&
sudo sed -i.bak -e "s/DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/g" /etc/apache2/mods-enabled/dir.conf &&
sudo wget -q https://raw.githubusercontent.com/danielcregg/simple-php-website/main/index.php -P /var/www/html/ &&
sudo rm -f /var/www/html/index.html &&
sudo chown -R www-data:www-data /var/www &&
sudo systemctl restart apache2 &&

echo "Enabling root login for SFTP..." &&
sudo sed -i "/PermitRootLogin/c\PermitRootLogin yes" /etc/ssh/sshd_config &&
echo "root:tester" | sudo chpasswd &&
sudo systemctl restart sshd &&

echo "Installing VS Code CLI for tunnel access..." &&
sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg &&
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ &&
sudo sh -c "echo '\''deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main'\'' > /etc/apt/sources.list.d/vscode.list" &&
sudo apt update -qq -y &&
sudo apt install code -qq -y &&
sudo code --install-extension ms-vscode.remote-server &&
rm -f packages.microsoft.gpg &&

###########################################
# Final Status Output
###########################################
printf "\nClick on this link to open your website: \e[3;4;33mhttp://$(dig +short myip.opendns.com @resolver1.opendns.com)\e[0m\n"
printf "\nClick on this link to download WinSCP \e[3;4;33mhttps://dcus.short.gy/downloadWinSCP\e[0m - Note: User name = root and password = tester\n"
printf "\nRun this command to open a VS Code tunnel: \e[3;4;33msudo code tunnel\e[0m\n"
echo "Staying logged into this new VM"
echo "Done."
bash -l
'
