# Networking Sandbox. Isolate the network logic from application logic

resource "aws_vpc" "main" {
    cidr_block          = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {

        Name = "jru-pulse-vpc"
        Env = "dev"
    }
}

# IG
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.project_name}-igw"
    }
}

#SN Public
resource "aws_subnet" "public_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-southeast-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.project_name}-public-1"
    } 
}

resource "aws_subnet" "public_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-southeast-1b"
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.project_name}-public-2"
    }
}

# SN Private
resource "aws_subnet" "private_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.11.0/24"
    availability_zone = "ap-southeast-1a"

    tags = {
        Name = "${var.project_name}-private-1"
    }
}

resource "aws_subnet" "private_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.12.0/24"
    availability_zone = "ap-southeast-1b"

    tags = {
        Name = "${var.project_name}-private-2"
    }
  
}

# Public RT
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "${var.project_name}-public-rt"
    }
}


resource "aws_route_table_association" "public_1" {
    subnet_id = aws_subnet.public_1.id
    route_table_id =  aws_route_table.public.id
}


resource "aws_route_table_association" "public_2" {
    subnet_id = aws_subnet.public_2.id
    route_table_id = aws_route_table.public.id
}


# Private Route Table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.project_name}-private-rt"
    }
}

resource "aws_route_table_association" "private_1" {
    subnet_id = aws_subnet.private_1.id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
    subnet_id = aws_subnet.private_2.id
    route_table_id = aws_route_table.private.id
}