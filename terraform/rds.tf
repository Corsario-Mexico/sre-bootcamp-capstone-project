# RDS Definition

# Subnet group
resource "aws_db_subnet_group" "David_Sol_rds_subnet_group" {
  name        = "david_sol_rds_subnet_group"
  description = "For the capstone database"
  subnet_ids  = aws_subnet.David_Sol_private_subnets.*.id
  tags = {
    Name = "David_Sol_rds_subnet_group"
  }
}

# Security group
resource "aws_security_group" "David_Sol_rds_security_group" {
  name        = "David_Sol_rds_security_group"
  description = "For the capstone database"
  vpc_id      = aws_vpc.David_Sol_vpc.id
  tags = {
    Name = "David_Sol_rds_security_group"
  }
}

# Ingress rules
resource "aws_security_group_rule" "David_Sol_rds_sg_ingress_frontend" {
  description              = "Access from the frontend instances"
  security_group_id        = aws_security_group.David_Sol_rds_security_group.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = aws_db_instance.David_Sol_rds_instance.port
  to_port                  = aws_db_instance.David_Sol_rds_instance.port
  source_security_group_id = aws_security_group.David_Sol_frontend_security_group.id
}

resource "aws_security_group_rule" "David_Sol_rds_sg_ingress_bastion" {
  description              = "Access from the bastion instance"
  security_group_id        = aws_security_group.David_Sol_rds_security_group.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = aws_db_instance.David_Sol_rds_instance.port
  to_port                  = aws_db_instance.David_Sol_rds_instance.port
  source_security_group_id = aws_security_group.David_Sol_bastion_security_group.id
}

# Egress rule
resource "aws_security_group_rule" "David_Sol_rds_sg_egress" {
  description       = "All allowed"
  security_group_id = aws_security_group.David_Sol_rds_security_group.id
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

# MySQL RDS instance
resource "aws_db_instance" "David_Sol_rds_instance" {
  identifier                   = "project-rds"
  engine                       = "mysql"
  engine_version               = "8.0.23"
  instance_class               = "db.t2.micro"
  allocated_storage            = 20
  max_allocated_storage        = 0
  db_subnet_group_name         = aws_db_subnet_group.David_Sol_rds_subnet_group.name
  availability_zone            = data.aws_availability_zones.available_azs.names[0]
  vpc_security_group_ids       = [aws_security_group.David_Sol_rds_security_group.id]
  publicly_accessible          = false
  name                         = "David_Sol_db"
  username                     = "admin"
  password                     = var.rds_password
  skip_final_snapshot          = true
  delete_automated_backups     = true
  performance_insights_enabled = false
  tags = {
    Name = "David_Sol_rds"
  }
}