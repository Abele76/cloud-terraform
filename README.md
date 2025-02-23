# cloud-terraform

# Azure Terraform Infrastructure

## Overview
This project provisions an Azure infrastructure in a Development Environment using Terraform. The resources created include:  
 
- Resource Groups
- A Virtual Network with a Subnet
- A Network Security Group with a rule allowing inbound traffic
- A Public IP Address
- A Network Interface
- An Ubuntu Virtual Machine

## Pre-requisites
Ensure you have the following installed:
- Terraform
- Azure CLI
- SSH Key for authorisation (~/.ssh/abeleazurekey.pub)

## Setup

1. Clone the repository:
   ```bash
    git clone https://github.com/Abele76/cloud-terraform
    cd cloud-terraform
    ```
2. Login to Azure:
    ```bash
    az login
    ```
3. Initialise Terraform
    ```bash
    terraform init
    ```
4. Plan the deployment:
    ```bash
    terraform plan
    ```
5. Apply the deployment:
    ```bash
    terraform apply -auto-approve
    ```

## Resources Created

- **Resource Groups**: abele-resources
- **Virtual Network**: abele-network
- **Subnet**: abele-subnet
- **Network Security Group**: abele-nsg with inbound rule abele-dev-rule
- **Public IP Address**: abele-ip
- **Network Interface**: abele-nic
- **Ubuntu Virtual Machine**: abele-vm with SSH access

## Accessing the Virtual Machine

After deploying, obtain the public IP:
 ```bash
 echo $(terraform output public_ip_address)
 ```
Then connect via SSH:
```bash
ssh -i ~/.ssh/abeleazurekey adminuser@<public-ip>
```
## Clean up

To destroy the resource:
```bash
terraform destroy -auto-approve
```

## Notes

- The VM uses Ubuntu 22.04 LTS.
- The SSH key must be present in ~/.ssh/abeleazurekey.pub
- Modify customdata.tpl for any cloud-init customizations.
