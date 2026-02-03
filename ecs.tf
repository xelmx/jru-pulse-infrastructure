
resource "aws_ecs_cluster" "main" {
    name = "${var.project_name}-ecs-cluster"

    setting {
        name = "containerInsights" #Activates Cloudwatch container Insights
        value = "enabled"
    }

    tags = {
        Name = "${var.project_name}-ecs-cluster"
    }
}



