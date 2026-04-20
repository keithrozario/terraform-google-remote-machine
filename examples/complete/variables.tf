variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The GCP region"
  default     = "asia-southeast1"
}

variable "zone" {
  type        = string
  description = "The GCP zone"
  default     = "asia-southeast1-a"
}

variable "network_self_link" {
  type        = string
  description = "Self-link of an existing VPC network"
}

variable "subnetwork_self_link" {
  type        = string
  description = "Self-link of an existing subnetwork"
}
