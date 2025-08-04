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
