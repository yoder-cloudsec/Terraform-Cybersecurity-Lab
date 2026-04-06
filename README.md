Low-cost ($0.14/hr) Cybersecurity Homelab Environment in AWS, featuring:

-**Kali Linux** - Attacker machine for penetration testing

-**Windows Target** - Defensive security practice environment  

-**Security Tools** - Ubuntu instance with security monitoring tools

Perfect for:

-**Penetration testing practice** - Safe, isolated environment

-**Blue team training** - Defensive security exercises
  
-**Certification prep** - OSCP, CEH, Security+, and more

-**Security research** - Malware analysis, vulnerability testing

### To Deploy:

- Clone the repository `git clone https://github.com/yoder-cloudsec/Terraform-Cybersecurity-Lab.git`

- Edit `aws.tfvars` and `main.tf` appropriately, using your AWS region, keypair and your home IP.

- `terraform init`
  
  `terraform plan`
  
  `terraform apply`

- Connect via SSH/RDP

- `terraform destroy` when you're done

### Security Features

   - IP Whitelisting - All security groups restricted to your home IP only

   - Isolated VPC - Complete network isolation from other AWS resources

   - Minimal Exposure - Only required ports (SSH, RDP, HTTP) are open

   - Cost Controls - Auto-shutdown tags for scheduled instance stopping

### Disclaimer

This lab is for educational purposes only. Always:

   - Use in isolated environments

   - Don't attack systems without permission

   - Don't use in production environments

   - Comply with all applicable laws
