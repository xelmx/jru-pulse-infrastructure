data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Entry point - SG for Bastion Host
resource "aws_security_group" "bastion" {
    name = "${var.project_name}-bastion-sg"
    description = "Allow SSH from my IP"
    vpc_id = aws_vpc.main.id
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "bastion" {
    ami = data.aws_ami.ubuntu.id 
    instance_type = "t3.micro"
    subnet_id = aws_subnet.public_1.id
    vpc_security_group_ids = [aws_security_group.bastion.id]

    key_name = "jru-pulse-key"

    tags = {
        Name = "${var.project_name}-bastion"
    }
}

resource "aws_security_group_rule" "allow_bastion_rds" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_group_id = aws_security_group.rds.id
    source_security_group_id = aws_security_group.bastion.id  
}

