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
  description = "The self-link or name of an existing VPC network. If null, a new network and subnet are created automatically"
  default     = null

  validation {
    condition     = var.network == null || var.subnetwork != null
    error_message = "subnetwork must be provided when network is specified"
  }
}

variable "subnetwork" {
  type        = string
  description = "The self-link or name of an existing subnetwork. Required when network is provided; ignored when network is null"
  default     = null
}

variable "subnet_cidr" {
  type        = string
  description = "The CIDR range for the auto-created subnet. Only used when network is null"
  default     = "10.0.0.0/16"
}

variable "machine_type" {
  type        = string
  description = "The machine type for compute instances"
  default     = "e2-standard-2"
}

variable "image" {
  type        = string
  description = "The source image family or self-link for the instance boot disk"
  default     = "ubuntu-os-cloud/ubuntu-2504-amd64"
}

variable "disk_size_gb" {
  type        = number
  description = "The size of the boot disk in GB"
  default     = 50
}

variable "disk_iops" {
  type        = number
  description = "Provisioned IOPS for the boot disk. Only valid for hyperdisk disk types; leave null for standard persistent disks"
  default     = null
}

variable "disk_throughput" {
  type        = number
  description = "Provisioned throughput in MB/s for the boot disk. Only valid for hyperdisk disk types; leave null for standard persistent disks"
  default     = null
}

variable "static_ip" {
  type        = string
  description = "Static internal IP address for the primary instance. If null, an IP is assigned automatically"
  default     = null
}

variable "allowed_ports" {
  type        = list(number)
  description = "TCP ports opened through the IAP firewall when the network is auto-created. Defaults to SSH only"
  default     = [22]
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
