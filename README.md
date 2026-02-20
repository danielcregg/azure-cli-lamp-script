# Azure CLI LAMP Script

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=flat-square&logo=microsoftazure&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)

A Bash script that automates the provisioning of a fully configured LAMP (Linux, Apache, MySQL, PHP) stack on an Azure virtual machine using the Azure CLI. Designed to be run directly from Azure Cloud Shell for quick classroom or development setups.

## Overview

This script handles the complete lifecycle of deploying a web server on Azure -- from resource group creation to software installation. It tears down any previous deployment, provisions a fresh Ubuntu 22.04 LTS VM, installs the full LAMP stack, and configures remote access tools including SFTP and VS Code tunnels.

## Features

- One-command deployment via Azure Cloud Shell
- Automatic cleanup of previous resource groups before redeployment
- Ubuntu 22.04 LTS VM provisioned with SSH and password authentication
- Full LAMP stack installation (Apache, MySQL, PHP)
- Apache configured to prioritize `index.php` over `index.html`
- Sample PHP website deployed from GitHub
- Root SFTP access enabled for file management
- VS Code remote tunnel support for browser-based editing
- Ports 80, 443, and 3389 opened automatically

## Prerequisites

- An active [Microsoft Azure](https://azure.microsoft.com/) subscription (Azure for Students supported)
- Access to [Azure Cloud Shell](https://shell.azure.com/) (Bash)

## Getting Started

### Installation

1. Log into the [Azure Portal](https://portal.azure.com/)
2. Open **Cloud Shell** (Bash environment)

### Usage

Run the following one-liner:

```bash
bash <(curl -sL tinyurl.com/azureLamp)
```

The script takes approximately 3 minutes to complete.

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

## Tech Stack

- **Shell:** Bash
- **Cloud Platform:** Microsoft Azure (VM, Resource Groups, Networking)
- **Web Server:** Apache
- **Database:** MySQL
- **Language:** PHP
- **OS:** Ubuntu 22.04 LTS

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
