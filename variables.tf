variable "project_id" {
  type        = string
  description = "The GCP project ID where resources will be created"
}

variable "name" {
  type        = string
  description = "Name prefix for all resources created by this module"
  default     = "remote-machine"
}

variable "region" {
  type        = string
  description = "The GCP region where resources will be deployed"
}

variable "zone" {
  type        = string
  description = "The GCP zone where compute instances will be deployed"
}

variable "network" {
  type        = string
  description = "The self-link or name of the VPC network to deploy instances into"
}

variable "subnetwork" {
  type        = string
  description = "The self-link or name of the subnetwork to deploy instances into"
}

variable "machine_type" {
  type        = string
  description = "The machine type for compute instances"
  default     = "c4d-standard-4"
}

variable "ubuntu_image" {
  type        = string
  description = "The source image family or self-link for the Ubuntu instance boot disk"
  default     = "ubuntu-os-cloud/ubuntu-2504-amd64"
}

variable "windows_image" {
  type        = string
  description = "The source image family or self-link for the Windows instance boot disk"
  default     = "windows-cloud/windows-2022"
}

variable "disk_size_gb" {
  type        = number
  description = "The size of the boot disk in GB"
  default     = 1000
}

variable "disk_iops" {
  type        = number
  description = "Provisioned IOPS for the boot disk (hyperdisk types only)"
  default     = 3500
}

variable "disk_throughput" {
  type        = number
  description = "Provisioned throughput in MB/s for the boot disk (hyperdisk types only)"
  default     = 200
}

variable "ubuntu_static_ip" {
  type        = string
  description = "Static internal IP address for the Ubuntu instance. If null, an IP is assigned automatically"
  default     = null
}

variable "windows_static_ip" {
  type        = string
  description = "Static internal IP address for the Windows instance. If null, an IP is assigned automatically"
  default     = null
}

variable "create_windows_instance" {
  type        = bool
  description = "Whether to create a Windows compute instance alongside the Ubuntu instance"
  default     = true
}

variable "schedule_timezone" {
  type        = string
  description = "The IANA timezone for the weekday start/stop schedule (e.g. 'Asia/Singapore', 'America/New_York')"
  default     = "Asia/Singapore"
}

variable "enable_apis" {
  type        = bool
  description = "Whether to enable required GCP APIs. Set to false if APIs are already enabled or managed externally"
  default     = true
}
