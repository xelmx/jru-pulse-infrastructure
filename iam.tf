# 1. ECS Task Execution Role - Allows the ECS Agent to pull images from ECR and send logs to CloudWatch
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Standard AWS Policy for ECS Execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 2. ECS Task Role - Python/PHP code uses WHILE running.
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Policy to allow ECS to read secret

resource "aws_iam_policy" "secrets_policy" {
  name = "${var.project_name}-secrets-policy"
  description = "Allow ECS to read DB secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["secretsmanager:GetSecretValue", "kms:Decrypt"]
        Effect = "Allow"
        Resource = [aws_secretsmanager_secret.db_credentials.arn]
      }
    ]
  })
}

# Attach this policy to the Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_secrets_attach" {
  role = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn
  
}


resource "aws_iam_openid_connect_provider" "github" {
   url = "https://token.actions.githubusercontent.com"
   client_id_list = ["sts.amazonaws.com"]
   thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:xelmx/*:*"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy" "github_cicd_permissions" {
  name = "${var.project_name}-github-cicd-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # push to ECR
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetImage",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        #  update ECS
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
