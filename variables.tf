variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "domain" {
  description = "Domain name pointing to the VM"
  type        = string
}

variable "n8n_basic_auth_password" {
  description = "Basic auth password for n8n"
  type        = string
  sensitive   = true
}

variable "gcs_backup_bucket" {
  description = "GCS bucket for n8n backups"
  type        = string
}

variable "scripts_repo_url" {
  description = "The raw GitHub URL for the scripts directory (e.g., https://raw.githubusercontent.com/user/repo/main)"
  type        = string
}
