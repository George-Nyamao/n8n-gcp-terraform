provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "n8n_vm" {
  name         = "n8n-server"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
      size  = 10 # Under 30GB free tier
    }
  }

  network_interface {
    network = "default"
    access_config {} # Required for external IP
  }

  metadata_startup_script = templatefile("startup.sh", {
    DOMAIN           = var.domain
    N8N_PASSWORD     = var.n8n_basic_auth_password
    GCS_BUCKET       = var.gcs_backup_bucket
    SCRIPTS_REPO_URL = var.scripts_repo_url
  })

  tags = ["n8n"]

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags   = ["n8n"]
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}
