provider "google" {
  project = var.project_id
  region  = var.region
}

module "linux_machine" {
  source = "../.."

  project_id = var.project_id
  name       = "dev-linux"
  region     = var.region
  zone       = var.zone

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  image        = "ubuntu-os-cloud/ubuntu-2504-amd64"
  machine_type = "e2-standard-2"
  static_ip    = "10.0.0.6"

  allowed_ports     = [22, 8080]
  schedule_timezone = "Asia/Singapore"
}

module "windows_machine" {
  source = "../.."

  project_id = var.project_id
  name       = "dev-windows"
  region     = var.region
  zone       = var.zone

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  image        = "windows-cloud/windows-2022"
  machine_type = "e2-standard-2"
  static_ip    = "10.0.0.7"

  allowed_ports     = [3389]
  schedule_timezone = "Asia/Singapore"
}
