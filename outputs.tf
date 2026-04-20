output "ubuntu_instance_id" {
  description = "The ID of the Ubuntu compute instance"
  value       = google_compute_instance.ubuntu.id
}

output "ubuntu_instance_name" {
  description = "The name of the Ubuntu compute instance"
  value       = google_compute_instance.ubuntu.name
}

output "ubuntu_instance_self_link" {
  description = "The self-link of the Ubuntu compute instance"
  value       = google_compute_instance.ubuntu.self_link
}

output "service_account_email" {
  description = "The email address of the service account used by the instances"
  value       = google_service_account.this.email
}

output "weekday_schedule_id" {
  description = "The ID of the weekday scheduling resource policy"
  value       = google_compute_resource_policy.weekday_schedule.id
}

output "network_self_link" {
  description = "The self-link of the VPC network used by the instances (created or provided)"
  value       = local.resolved_network
}

output "subnetwork_self_link" {
  description = "The self-link of the subnetwork used by the instances (created or provided)"
  value       = local.resolved_subnetwork
}
