locals {
  required_apis = toset([
    "compute.googleapis.com",
    "storage.googleapis.com",
  ])
}

resource "google_project_service" "this" {
  for_each           = var.enable_apis ? local.required_apis : toset([])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "this" {
  account_id   = var.name
  display_name = var.name
  project      = var.project_id
}

resource "google_compute_instance" "ubuntu" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id

  tags = ["allow-health-check"]

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
    network_ip = var.static_ip
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

  metadata_startup_script = var.startup_script
}

resource "google_compute_resource_policy" "weekday_schedule" {
  name        = "${var.name}-weekday-schedule"
  region      = var.region
  project     = var.project_id
  description = "Starts instances at 7am and stops them at 7pm on weekdays"

  instance_schedule_policy {
    vm_start_schedule {
      schedule = "0 7 * * 1-5"
    }
    vm_stop_schedule {
      schedule = "0 19 * * 1-5"
    }
    time_zone = var.schedule_timezone
  }
}
