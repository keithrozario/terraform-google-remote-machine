provider "google" {
  project = var.project_id
  region  = var.region
}

module "remote_machine" {
  source = "../.."

  project_id = var.project_id
  name       = "dev-machine"
  region     = var.region
  zone       = var.zone

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  machine_type  = "c4d-standard-4"
  ubuntu_image  = "ubuntu-os-cloud/ubuntu-2504-amd64"
  windows_image = "windows-cloud/windows-2022"

  ubuntu_static_ip  = "10.0.0.6"
  windows_static_ip = "10.0.0.7"

  disk_size_gb    = 1000
  disk_iops       = 3500
  disk_throughput = 200

  create_windows_instance = true
  schedule_timezone       = "Asia/Singapore"

  enable_apis = true
}
