resource "google_compute_instance" "windows" {
  count = var.create_windows_instance ? 1 : 0

  name         = "${var.name}-windows"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["allow-health-check", "allow-rdp"]

  boot_disk {
    auto_delete = false
    initialize_params {
      image                  = var.image
      size                   = var.disk_size_gb
      provisioned_iops       = var.disk_iops
      provisioned_throughput = var.disk_throughput
    }
  }

  network_interface {
    network    = local.resolved_network
    subnetwork = local.resolved_subnetwork
    network_ip = null
  }

  lifecycle {
    create_before_destroy = false
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  service_account {
    email  = google_service_account.this.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
