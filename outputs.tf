output "instance_public_ip_win" {
  value = "Windows Box IP Address: ${aws_instance.windows.public_ip}"
}

output "instance_public_ip_kali" {
  value = "Kali Box IP Address: ${aws_instance.kali.public_ip}"
}

output "instance_public_ip_security-tools" {
  value = "Security Tools Box IP Address: ${aws_instance.security-tools.public_ip}"
}

output "kali_public_ip" {
  value = aws_instance.kali.public_ip
  description = "Kali Linux public IP for SSH connections"
}

output "instance_ids" {
  value = {
    kali   = aws_instance.kali.id
    windows = aws_instance.windows.id
    tools  = aws_instance.security-tools.id
  }
  description = "Instance IDs for manual management"
}
