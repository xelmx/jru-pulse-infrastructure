# Python API log group

resource "aws_cloudwatch_log_group" "python_api" {
    name = "/ecs/${var.project_name}-python-api"
    retention_in_days = 7

    tags ={
        Name = "${var.project_name}-python-api-logs"
    }
}


# PHP Web App Log group
resource "aws_cloudwatch_log_group" "web_app" {
    name = "/ecs/${var.project_name}-web-app"
    retention_in_days = 7

    tags = {
        Name = "${var.project_name}-web-app-logs"
    }
}