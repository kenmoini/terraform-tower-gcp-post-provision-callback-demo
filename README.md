# Provision GCE VMs with Ansible Tower Provisioning Callbacks

This repo is a simple demo of how you can use Terraform to create your infrastructure to Google Cloud and utilize Ansible Tower for the provisioning and configuration.

## Prerequisites

### Install Terraform

Read more here: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

```bash
# RHEL Systems
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
```

### Install Google Cloud CLI

Read more here: https://cloud.google.com/sdk/docs/install

```bash
# RHEL Systems
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

# Install the package
sudo dnf install google-cloud-cli

# Log in
gcloud init
```

## Usage

### Tower Setup

1. Deploy Ansible Tower - Set up RBAC and other basics
2. Add this Git repo as a ***Project*** in Ansible Tower
3. Create a Google Cloud type ***Credential*** in Tower so it can connect to GCP and sync the inventory - this Service Account can have Read-only access.  Create a JSON type Key for the Service Account.
4. Create a Machine type ***Credential*** in Tower that will match the the user credentials that have access to GCE VMs, set the user to `nuser`
5. In Tower, create an ***Inventory*** for your GCE environment and have it use GCE as a ***Source***
   
    Ensure that the checkboxes for **Overwrite** and **Update on Launch** are checked in the Inventory Source so that it is updated as soon as the Provisioning Job Template is called

    Additional Overrides and GCE Sync Variables can be found here: https://docs.ansible.com/ansible/latest/collections/google/cloud/gcp_compute_inventory.html

6. Set up a ***Job Template*** using the previously created GCP ***Credential***, the GCE ***Inventory***, and ***Project***.  Select the `configure-system.yaml` Playbook.

    Ensure that the checkboxes for **Enable Privilege Escalation** and **Enable Provisioning Callbacks** are checked in the Job Template.  Click the Refresh button to the right of the **Host Config Key** input box, then click **Save**.

    Take note of the Job ID number, Host Config Key, and of course the FQDN of your Ansible Tower instance.  This will be used with the Terraform deployer.

### Deployment

This simple demo is ran from a workstation - not tested with the Terraform Cloud

1. Ensure you have the `gcloud` and Terrform CLIs installed
2. Configure your credentials accordingly: https://registry.terraform.io/providers/hashicorp/google/latest/docs
3. Clone this repo down `git clone https://github.com/kenmoini/terraform-tower-gcp-post-provision-callback-demo`
4. Enter the infrastructure directory `cd terraform-tower-gcp-post-provision-callback-demo/infra`
5. Modify the `main.tf` file, swapping variables where needed
6. Run `terraform init && terraform apply` - type in `yes` when prompted.
7. Watch the GCE VM deploy in the Google Cloud GUI, and watch the Job Template run against the new VM in Tower once it is launched.
8. ????????
9. PROFIT!!!!!!1