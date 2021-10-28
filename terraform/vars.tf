# Number of Availability Zones to use
variable "azs_to_use" {
  description = "Number of AZs to use"
  type        = number
  default     = 2
}

# CIDR for the VPC
variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "172.30.0.0/16"
}

# Extra bits for each subnet
# Meaning extra bits to add to the Subnet mask
# Ej: If VPC CIDR = 192.168.0.0/16 and Extra bits are 8
#     the first subnet will be 192.168.0.0/24
#     and the second subnet    192.168.8.0/24
variable "subnet_extra_bits" {
  description = "Extra bits for each subnet CIDR"
  type        = number
  default     = 4
}

# Instance AMI
variable "instance_ami" {
  description = "AMI for the webserver instances"
  type        = string
  default     = "ami-013a129d325529d4d"
}

# Instance Key
variable "instance_key" {
  description = "SSH Key for the instances"
  type        = string
  default     = "davidsolcapstone"
}

# Hidden in the log, but appears in the state
# Will ask for the value every time unless set up as an env variable
variable "rds_password" {
  description = "Password for the RDS DB server"
  type        = string
  sensitive   = true
}

# Get the current region
data "aws_region" "current_region" {}

# Get my IP address for the Bastion SG
data "http" "my_ip_address" {
  url = "https://ipv4.icanhazip.com"
}
