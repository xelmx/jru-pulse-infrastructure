# Python API task Definition
resource "aws_ecs_task_definition" "python_api" {
    family = "${var.project_name}-python-api"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = "2048"
    memory = "4096"
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn = aws_iam_role.ecs_task_role.arn

    container_definitions = jsonencode([
        {
            name = "python-api"
            image = "508972673137.dkr.ecr.ap-southeast-1.amazonaws.com/jru-pulse-python-api:latest"
            essential = true
            portMappings = [
                {
                    containerPort = 8000
                    hostPort = 8000
                }
            ]
            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    "awslogs-group" = aws_cloudwatch_log_group.python_api.name
                    "awslogs-region" = var.aws_region
                    "awslogs-stream-prefix" = "ecs"
                }
            }
        }
    ])
}

# Python API Service
resource "aws_ecs_service" "python_api" {
  name = "${var.project_name}-python-service"
  cluster = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.python_api.arn
  desired_count = var.app_count
  launch_type = "FARGATE"
  

  network_configuration {
    subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id] 

    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.python_api.arn
    container_name = "python-api"
    container_port = 8000
  }
}


# PHP Web App Task Definition
resource "aws_ecs_task_definition" "web_app" {
  family = "${var.project_name}-web-app"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256" 
  memory = "512"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name = "web-app"
      image  = "508972673137.dkr.ecr.ap-southeast-1.amazonaws.com/jru-pulse-web-app:latest"
      essential = true
     
      secrets = [
          { name = "MYSQL_USER", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:username::"},
          { name = "MYSQL_PASSWORD", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:password::"},
          { name = "MYSQL_HOST", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:host::"},
          { name = "MYSQL_DATABASE", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:db_name::"},
          { name = "GOOGLE_CLIENT_ID", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:google_client_id::"},
          { name = "GOOGLE_REDIRECT_URI", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:google_redirect_uri::" },
          { name = "GOOGLE_CLIENT_SECRET", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:google_client_secret::" },
          { name = "MAIL_HOST", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:mail_host::" },
          { name = "MAIL_PORT", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:mail_port::" },
          { name = "MAIL_USERNAME", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:mail_username::" },
          { name = "MAIL_PASSWORD", valueFrom = "${aws_secretsmanager_secret.db_credentials.arn}:mail_password::" }
      ]

      portMappings = [
        {
          containerPort = 80
          hostPort = 80
        }
      ]
      environment = [
        { name = "AI_PYTHON_API", value = "http://${aws_lb.main.dns_name}/ai" },
        { name  = "APP_BASE_URL", value = "https://dnzjwkw4fgfzp.cloudfront.net"}
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"  = aws_cloudwatch_log_group.web_app.name
          "awslogs-region" = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# PHP Web App Service
resource "aws_ecs_service" "web_app" {
  name            = "${var.project_name}-web-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.web_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_app.arn
    container_name   = "web-app"
    container_port   = 80
  }
}