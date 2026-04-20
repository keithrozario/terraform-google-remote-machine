mock_provider "google" {
  mock_resource "google_compute_network" {
    defaults = {
      self_link = "https://www.googleapis.com/compute/v1/projects/mock-project/global/networks/mock-network"
    }
  }

  mock_resource "google_compute_subnetwork" {
    defaults = {
      self_link = "https://www.googleapis.com/compute/v1/projects/mock-project/regions/us-central1/subnetworks/mock-subnet"
    }
  }

  mock_resource "google_service_account" {
    defaults = {
      email = "mock-sa@mock-project.iam.gserviceaccount.com"
    }
  }
}

# Common variables shared across all runs
variables {
  project_id = "mock-project"
  region     = "us-central1"
  zone       = "us-central1-a"
}

# --- Network creation ---

run "auto_creates_network_when_not_provided" {
  command = plan

  assert {
    condition     = length(google_compute_network.this) == 1
    error_message = "Expected a VPC network to be created when network is null"
  }

  assert {
    condition     = length(google_compute_subnetwork.this) == 1
    error_message = "Expected a subnetwork to be created when network is null"
  }

  assert {
    condition     = length(google_compute_router.this) == 1
    error_message = "Expected a Cloud Router to be created when network is null"
  }

  assert {
    condition     = length(google_compute_router_nat.this) == 1
    error_message = "Expected Cloud NAT to be created when network is null"
  }

  assert {
    condition     = length(google_compute_firewall.iap) == 1
    error_message = "Expected IAP firewall rule to be created when network is null"
  }

  assert {
    condition     = toset(flatten([for a in google_compute_firewall.iap[0].allow : a.ports])) == toset(["22"])
    error_message = "Expected default firewall to open port 22 only"
  }
}

run "uses_existing_network_when_provided" {
  command = plan

  variables {
    network    = "projects/mock-project/global/networks/existing-network"
    subnetwork = "projects/mock-project/regions/us-central1/subnetworks/existing-subnet"
  }

  assert {
    condition     = length(google_compute_network.this) == 0
    error_message = "Expected no VPC network to be created when one is provided"
  }

  assert {
    condition     = length(google_compute_subnetwork.this) == 0
    error_message = "Expected no subnetwork to be created when one is provided"
  }

  assert {
    condition     = length(google_compute_router_nat.this) == 0
    error_message = "Expected no Cloud NAT when a network is provided"
  }

  assert {
    condition     = length(google_compute_firewall.iap) == 0
    error_message = "Expected no firewall rules when a network is provided"
  }

  assert {
    condition     = output.network_self_link == "projects/mock-project/global/networks/existing-network"
    error_message = "Expected network_self_link output to reflect the provided network"
  }

  assert {
    condition     = output.subnetwork_self_link == "projects/mock-project/regions/us-central1/subnetworks/existing-subnet"
    error_message = "Expected subnetwork_self_link output to reflect the provided subnetwork"
  }
}

run "custom_subnet_cidr_applied_to_auto_created_subnet" {
  command = plan

  variables {
    subnet_cidr = "192.168.0.0/24"
  }

  assert {
    condition     = google_compute_subnetwork.this[0].ip_cidr_range == "192.168.0.0/24"
    error_message = "Expected the auto-created subnet to use the custom CIDR range"
  }
}

# --- Validation ---

run "validation_fails_when_network_provided_without_subnetwork" {
  command = plan

  expect_failures = [var.network]

  variables {
    network = "projects/mock-project/global/networks/existing-network"
    # subnetwork intentionally omitted
  }
}

# --- Machine type and image ---

run "custom_machine_type_applied" {
  command = plan

  variables {
    machine_type = "n2-standard-8"
  }

  assert {
    condition     = google_compute_instance.ubuntu.machine_type == "n2-standard-8"
    error_message = "Expected instance to use the custom machine type"
  }
}

run "custom_image_applied" {
  command = plan

  variables {
    image = "windows-cloud/windows-2022"
  }

  assert {
    condition     = google_compute_instance.ubuntu.boot_disk[0].initialize_params[0].image == "windows-cloud/windows-2022"
    error_message = "Expected instance to use the custom image"
  }
}

run "custom_allowed_ports_applied" {
  command = plan

  variables {
    allowed_ports = [22, 3389, 8080]
  }

  assert {
    condition     = toset(flatten([for a in google_compute_firewall.iap[0].allow : a.ports])) == toset(["22", "3389", "8080"])
    error_message = "Expected firewall rule to include all specified ports"
  }
}

# --- Disk settings ---

run "default_disk_size_is_small" {
  command = plan

  assert {
    condition     = google_compute_instance.ubuntu.boot_disk[0].initialize_params[0].size == 50
    error_message = "Expected default disk size to be 50 GB"
  }
}

run "custom_disk_size_applied" {
  command = plan

  variables {
    disk_size_gb    = 500
    disk_iops       = 6000
    disk_throughput = 350
  }

  assert {
    condition     = google_compute_instance.ubuntu.boot_disk[0].initialize_params[0].size == 500
    error_message = "Expected instance to use the custom disk size"
  }

  assert {
    condition     = google_compute_instance.ubuntu.boot_disk[0].initialize_params[0].provisioned_iops == 6000
    error_message = "Expected instance to use the custom IOPS"
  }

  assert {
    condition     = google_compute_instance.ubuntu.boot_disk[0].initialize_params[0].provisioned_throughput == 350
    error_message = "Expected instance to use the custom throughput"
  }
}

# --- API enablement ---

run "apis_enabled_by_default" {
  command = plan

  assert {
    condition     = length(google_project_service.this) == 2
    error_message = "Expected compute and storage APIs to be enabled by default"
  }
}

run "apis_can_be_disabled" {
  command = plan

  variables {
    enable_apis = false
  }

  assert {
    condition     = length(google_project_service.this) == 0
    error_message = "Expected no API resources when enable_apis is false"
  }
}
