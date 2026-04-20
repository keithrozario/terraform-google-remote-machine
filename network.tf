locals {
  create_network = var.network == null

  resolved_network    = local.create_network ? google_compute_network.this[0].self_link : var.network
  resolved_subnetwork = local.create_network ? google_compute_subnetwork.this[0].self_link : var.subnetwork
}

resource "google_compute_network" "this" {
  count = local.create_network ? 1 : 0

  name                     = var.name
  project                  = var.project_id
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "this" {
  count = local.create_network ? 1 : 0

  name                     = "${var.region}-${var.name}"
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  project                  = var.project_id
  network                  = google_compute_network.this[0].self_link
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_30_SEC"
    flow_sampling        = 1.0
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "this" {
  count = local.create_network ? 1 : 0

  name    = var.name
  region  = var.region
  project = var.project_id
  network = google_compute_network.this[0].self_link
}

resource "google_compute_router_nat" "this" {
  count = local.create_network ? 1 : 0

  name                               = var.name
  router                             = google_compute_router.this[0].name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "iap_ssh" {
  count = local.create_network ? 1 : 0

  name    = "${var.name}-allow-iap-ssh"
  project = var.project_id
  network = google_compute_network.this[0].self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "iap_rdp" {
  count = local.create_network ? 1 : 0

  name    = "${var.name}-allow-iap-rdp"
  project = var.project_id
  network = google_compute_network.this[0].self_link

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "iap_port_forward" {
  count = local.create_network ? 1 : 0

  name    = "${var.name}-allow-iap-port-forward"
  project = var.project_id
  network = google_compute_network.this[0].self_link

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["35.235.240.0/20"]
}
