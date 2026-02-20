# Azure CLI LAMP Script

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=flat-square&logo=microsoftazure&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)
![Last Commit](https://img.shields.io/github/last-commit/danielcregg/azure-cli-lamp-script?style=flat-square)

A Bash script that automates the provisioning of a fully configured LAMP (Linux, Apache, MySQL, PHP) stack on an Azure virtual machine using the Azure CLI. Designed to be run directly from Azure Cloud Shell for quick classroom or development setups.

## What It Does

1. Deletes any existing `LAMPResourceGroupAuto` resource group to ensure a clean deployment
2. Creates a new resource group in the `northeurope` region under an Azure for Students subscription
3. Provisions an Ubuntu 22.04 LTS VM (`Standard_B2s`) with SSH and password authentication
4. Opens ports 80, 443, and 3389 on the VM
5. SSHs into the VM and installs Apache, MySQL, and PHP
6. Configures Apache to prioritize `index.php` over `index.html`
7. Deploys a sample PHP website from GitHub
8. Enables root login for SFTP file management
9. Installs VS Code for remote tunnel access via the browser

## Prerequisites

- An active [Microsoft Azure](https://azure.microsoft.com/) subscription (Azure for Students supported)
- Access to [Azure Cloud Shell](https://shell.azure.com/) (Bash)

## Getting Started

1. Log into the [Azure Portal](https://portal.azure.com/)
2. Open **Cloud Shell** (Bash environment)
3. Run the following one-liner:

```bash
bash <(curl -sL tinyurl.com/azureLamp)
```

The script takes approximately 3 minutes to complete.

## Usage

Once the script finishes, it will display:

- A link to the default Apache web page served by your new VM
- A link to verify PHP is correctly installed (`/info.php`)
- Instructions for connecting via WinSCP (user: `root`, password: `tester`)
- Instructions for opening a VS Code tunnel for browser-based editing

## Configuration

The script uses the following defaults (edit `azureLamp.sh` to customize):

| Parameter       | Default Value              |
|-----------------|----------------------------|
| Resource Group  | `LAMPResourceGroupAuto`    |
| VM Name         | `LAMPServerAuto`           |
| VM Size         | `Standard_B2s`             |
| OS Disk Size    | 64 GB                      |
| Region          | `northeurope`              |
| Admin Username  | `azureuser`                |
| Ubuntu Image    | 22.04 LTS (Gen2)          |

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
