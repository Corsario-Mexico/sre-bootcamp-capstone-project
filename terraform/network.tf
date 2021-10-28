# Network definitions

# Identify AZs to use
data "aws_availability_zones" "available_azs" {
  state = "available"
}

# VPC
resource "aws_vpc" "David_Sol_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "David_Sol_vpc"
  }
}

# Default Route Table
resource "aws_default_route_table" "David_Sol_default_route_table" {
  default_route_table_id = aws_vpc.David_Sol_vpc.default_route_table_id
  tags = {
    Name = "David_Sol_default_route_table"
  }
}

# Default Security Group
resource "aws_default_security_group" "David_Sol_default_security_group" {
  vpc_id = aws_vpc.David_Sol_vpc.id

  // All Ingress and Egress blocked by Default
  //  ingress {
  //  }
  //  egress {
  //  }
  tags = {
    Name = "David_Sol_default_security_group"
  }
}

# Default NACL
resource "aws_default_network_acl" "David_Sol_default_nacl" {
  default_network_acl_id = aws_vpc.David_Sol_vpc.default_network_acl_id
  // All Ingress and Egress blocked by Default
  //  ingress {
  //  }
  //  egress {
  //  }
  tags = {
    Name = "David_Sol_default_nacl"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "David_Sol_default_igw" {
  vpc_id = aws_vpc.David_Sol_vpc.id
  tags = {
    Name = "David_Sol_default_igw"
  }
}

# Public Subnets
resource "aws_subnet" "David_Sol_public_subnets" {
  count                   = var.azs_to_use
  cidr_block              = cidrsubnet(var.vpc_cidr, var.subnet_extra_bits, count.index)
  vpc_id                  = aws_vpc.David_Sol_vpc.id
  availability_zone       = data.aws_availability_zones.available_azs.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "David_Sol_public_subnet_${count.index}"
  }
}

# Public Subnets Route Table
resource "aws_route_table" "David_Sol_public_subnets_route_table" {
  vpc_id = aws_vpc.David_Sol_vpc.id
  route {
    # Associated subnet can reach public internet
    cidr_block = "0.0.0.0/0"
    # Which internet gateway to use
    gateway_id = aws_internet_gateway.David_Sol_default_igw.id
  }
  tags = {
    Name = "David_Sol_public_subnets_route_table"
  }
}

resource "aws_route_table_association" "David_Sol_public_subnets_rt_assoc" {
  count          = var.azs_to_use
  route_table_id = aws_route_table.David_Sol_public_subnets_route_table.id
  subnet_id      = aws_subnet.David_Sol_public_subnets.*.id[count.index]
}

# Public NACL
resource "aws_network_acl" "David_Sol_public_subnets_nacl" {
  vpc_id     = aws_vpc.David_Sol_vpc.id
  subnet_ids = aws_subnet.David_Sol_public_subnets.*.id
  # Allow all ingress
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = -1
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
  # Allow all egress
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = -1
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    "Name" = "David_Sol_public_subnets_nacl"
  }
}

# Private Subnets
resource "aws_subnet" "David_Sol_private_subnets" {
  count                   = var.azs_to_use
  cidr_block              = cidrsubnet(var.vpc_cidr, var.subnet_extra_bits, count.index + var.azs_to_use)
  vpc_id                  = aws_vpc.David_Sol_vpc.id
  availability_zone       = data.aws_availability_zones.available_azs.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "David_Sol_private_subnet_${count.index}"
  }
}

# Elastic IP for the Private Subnets NAT Gateway
resource "aws_eip" "David_Sol_private_subnets_natgw_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.David_Sol_default_igw]
  tags = {
    Name = "David_Sol_private_subnets_natgw_eip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "David_Sol_private_subnets_natgw" {
  connectivity_type = "public"
  subnet_id         = aws_subnet.David_Sol_public_subnets.*.id[0]
  allocation_id     = aws_eip.David_Sol_private_subnets_natgw_eip.id
  tags = {
    Name = "David_Sol_private_subnets_natgw"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.David_Sol_default_igw]
}

# Private Route Table
resource "aws_route_table" "David_Sol_private_subnets_route_table" {
  vpc_id = aws_vpc.David_Sol_vpc.id
  route {
    # Associated subnet can reach public internet
    cidr_block = "0.0.0.0/0"
    # Which internet gateway to use
    nat_gateway_id = aws_nat_gateway.David_Sol_private_subnets_natgw.id
  }
  tags = {
    Name = "David_Sol_private_subnets_route_table"
  }
}

resource "aws_route_table_association" "David_Sol_private_subnets_rt_assoc" {
  count          = var.azs_to_use
  route_table_id = aws_route_table.David_Sol_private_subnets_route_table.id
  subnet_id      = aws_subnet.David_Sol_private_subnets.*.id[count.index]
}

# Private NACL
resource "aws_network_acl" "David_Sol_private_subnets_nacl" {
  vpc_id     = aws_vpc.David_Sol_vpc.id
  subnet_ids = aws_subnet.David_Sol_private_subnets.*.id
  # Allow all ingress from VPC only
  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = -1
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
  # Allow all egress
  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = -1
    from_port  = 0
    to_port    = 0
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    "Name" = "David_Sol_private_subnets_nacl"
  }
}

# VPC Endpoint to allow private instances to access S3
resource "aws_vpc_endpoint" "David_Sol_vpc_endpoint_s3" {
  vpc_id       = aws_vpc.David_Sol_vpc.id
  service_name = "com.amazonaws.${data.aws_region.current_region.name}.s3"
  policy       = file("vpc_endpoint_s3_policy.json")
  tags = {
    "Name" = "David_Sol_vpc_endpoint_s3"
  }
}

# associate route table with VPC endpoint
resource "aws_vpc_endpoint_route_table_association" "Private_route_table_association" {
  route_table_id  = aws_route_table.David_Sol_private_subnets_route_table.id
  vpc_endpoint_id = aws_vpc_endpoint.David_Sol_vpc_endpoint_s3.id
}