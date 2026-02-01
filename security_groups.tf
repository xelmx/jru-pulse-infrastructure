# created an ALB Security Group that allows public traffic on port 80. 
# Then, I created a Task Security Group that only accepts traffic if it originates from the ALB's Security Group ID. 
#This ensures that no one can bypass the Load Balancer to hit my containers directly, even if they are in a public subnet.

resource "aws_security_group" "alb" {
    name = "${var.project_name}-alb-sg"
    description = "Allow HTTP inbound traffic"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "HTTP from world"
        from_port = 80
        to_port = 80
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


resource "aws_security_group" "ecs_tasks" {
    name = "${var.project_name}-ecs-tasks-sg"
    description = "Allow inbound traffic from ALB only"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "Allow from ALB SG"
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = [aws_security_group.alb.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol ="-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}