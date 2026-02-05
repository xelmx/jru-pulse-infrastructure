# 1. The Application Load Balancer
resource "aws_lb" "main" { 
    name = "${var.project_name}-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb.id]
    subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]

    tags = {
        Name = "${var.project_name}-alb"
    }
}

# target Group for PHP Web App
resource "aws_lb_target_group" "web_app" { 
    name = "${var.project_name}-web-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    target_type = "ip" 

    health_check {
      path = "/"
      healthy_threshold = 3
      unhealthy_threshold = 3
      timeout = 5
      interval = 30
      matcher = "200"
    }
}

# Target Group for Python API
resource "aws_lb_target_group" "python_api" {
    name = "${var.project_name}-python-tg-v3"
    port = 8000
    protocol = "HTTP"
    vpc_id = aws_vpc.main.id
    target_type = "ip"

    health_check {
      path = "/docs"
      healthy_threshold   = 3
      unhealthy_threshold = 3
      timeout = 5
      interval = 30
      matcher = "200"
    }

     lifecycle {
      create_before_destroy = true
    }
}

# 4. Listener
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.main.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.web_app.arn
    }
}

# Listener Rule (Route /api/* to Python)
resource "aws_lb_listener_rule" "api_routing" {
    listener_arn = aws_lb_listener.http.arn
    priority  = 100

    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.python_api.arn
    }

    condition {
      path_pattern {
        values = ["/ai/*", "/nlp/*", "/docs", "/openapi.json"]
      }
    }
}