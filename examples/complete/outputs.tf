output "ubuntu_instance_name" {
  description = "The name of the Ubuntu compute instance"
  value       = module.remote_machine.ubuntu_instance_name
}

output "windows_instance_name" {
  description = "The name of the Windows compute instance"
  value       = module.remote_machine.windows_instance_name
}

output "service_account_email" {
  description = "The service account email used by the instances"
  value       = module.remote_machine.service_account_email
}
