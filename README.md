# Terraform n8n on GCP

This repository contains Terraform code to deploy a self-hosted n8n instance on Google Cloud Platform (GCP). The setup includes a Google Compute Engine (GCE) VM, Nginx as a reverse proxy, free SSL certificates from Let's Encrypt, and automated scripts for backups and updates.

## Prerequisites

Before you begin, ensure you have the following:

*   **Google Cloud Platform (GCP) Account:** You'll need a GCP account with billing enabled.
*   **GCP Project:** A GCP project with the Compute Engine API enabled.
*   **Terraform:** Terraform installed on your local machine.
*   **Domain Name:** A registered domain name that you can manage.
*   **Google Cloud Storage (GCS) Bucket:** A GCS bucket for storing backups. You will need to provide the name of this bucket in your configuration.
*   **DNS Configuration:** An A record for your domain pointing to the IP address of the GCE VM. You will get the IP address after the VM is created.

## Usage

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/YOUR-GITHUB-REPO/terraform-gcp-n8n.git
    cd terraform-gcp-n8n
    ```
    **Note:** Replace `YOUR-GITHUB-REPO` with your GitHub username or organization.

2.  **Configure your project:**
    Create a `terraform.tfvars` file and add the following, replacing the placeholder values:
    ```terraform
    project_id = "your-gcp-project-id"
    domain     = "n8n.your-domain.com"
    n8n_basic_auth_password = "a-very-secure-password"
    gcs_backup_bucket       = "name-of-your-gcs-bucket"
    scripts_repo_url        = "https://raw.githubusercontent.com/YOUR-GITHUB-REPO/terraform-gcp-n8n/main"
    ```

3.  **Initialize Terraform:**
    ```sh
    terraform init
    ```

4.  **Apply the Terraform configuration:**
    ```sh
    terraform apply
    ```
    Terraform will show you a plan and ask for confirmation. Type `yes` to proceed.

5.  **Update your DNS:**
    After the apply is complete, Terraform will output the IP address of the VM. Update the A record for your domain to point to this IP address.

6.  **Access your n8n instance:**
    Once DNS has propagated, you can access your n8n instance at `https://n8n.your-domain.com`.

## Configuration

The following variables can be set in your `terraform.tfvars` file:

| Variable                  | Description                                                                          | Type     | Default       |
|---------------------------|--------------------------------------------------------------------------------------|----------|---------------|
| `project_id`              | Your GCP project ID                                                                  | `string` | -             |
| `region`                  | The GCP region to deploy to                                                          | `string` | `us-central1` |
| `zone`                    | The GCP zone to deploy to                                                            | `string` | `us-central1-a` |
| `domain`                  | The domain name for your n8n instance                                                | `string` | -             |
| `n8n_basic_auth_password` | Basic auth password for n8n                                                          | `string` | -             |
| `gcs_backup_bucket`       | GCS bucket for n8n backups                                                           | `string` | -             |
| `scripts_repo_url`        | The raw GitHub URL for the scripts directory (e.g., https://raw.githubusercontent.com/user/repo/main) | `string` | -             |

## Scripts

This project includes two scripts that are automatically downloaded from the `scripts_repo_url` and set up on the n8n VM.

### `backup.sh`

This script creates a compressed tarball of the n8n data directory (`/root/n8n_data`) and uploads it to the GCS bucket you created. A cron job is set to run this script daily at 3:00 AM.

### `update.sh`

This script pulls the latest n8n Docker image and restarts the container to update your n8n instance. A cron job is set to run this script daily at 2:00 AM.
