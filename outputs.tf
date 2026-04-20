output "instance_id" {
  description = "The ID of the compute instance"
  value       = google_compute_instance.ubuntu.id
}

output "instance_name" {
  description = "The name of the compute instance"
  value       = google_compute_instance.ubuntu.name
}

output "instance_self_link" {
  description = "The self-link of the compute instance"
  value       = google_compute_instance.ubuntu.self_link
}

output "instance_ip" {
  description = "The internal IP address of the compute instance"
  value       = google_compute_instance.ubuntu.network_interface[0].network_ip
}

output "service_account_email" {
  description = "The email address of the service account used by the instance"
  value       = google_service_account.this.email
}

output "weekday_schedule_id" {
  description = "The ID of the weekday scheduling resource policy"
  value       = google_compute_resource_policy.weekday_schedule.id
}

output "network_self_link" {
  description = "The self-link of the VPC network used by the instance (created or provided)"
  value       = local.resolved_network
}

output "subnetwork_self_link" {
  description = "The self-link of the subnetwork used by the instance (created or provided)"
  value       = local.resolved_subnetwork
}
