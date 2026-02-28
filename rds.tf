# DB Subnet Group - RDS on which subnets to use
resource "aws_db_subnet_group" "main" {
    name = "${var.project_name}-db-subnet-group"
    subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

    tags = {
        Name = "${var.project_name}-db-subnet-group"
    }
}

# DB Security Group
resource "aws_security_group" "rds" {
  name = "${var.project_name}-rds-sg"
  description = "Allow inbound traffic to RDS"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_ecs_to_rds" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  security_group_id = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ecs_tasks.id
}

resource "aws_db_instance" "main" {
    identifier = "${var.project_name}-db"
    allocated_storage = 20
    max_allocated_storage = 100 
    db_name = "jru_pulse"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    username = "admin"
    password = "jrupulse2026"

    db_subnet_group_name = aws_db_subnet_group.main.name
    vpc_security_group_ids = [aws_security_group.rds.id]

    skip_final_snapshot = true #allow terra destroy to work quickly
    publicly_accessible = false # for security accesibility
    multi_az = false # false for development to save credits
  
}