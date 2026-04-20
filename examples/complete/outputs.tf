output "linux_instance_name" {
  description = "The name of the Linux compute instance"
  value       = module.linux_machine.instance_name
}

output "linux_instance_ip" {
  description = "The internal IP address of the Linux compute instance"
  value       = module.linux_machine.instance_ip
}

output "windows_instance_name" {
  description = "The name of the Windows compute instance"
  value       = module.windows_machine.instance_name
}

output "windows_instance_ip" {
  description = "The internal IP address of the Windows compute instance"
  value       = module.windows_machine.instance_ip
}
