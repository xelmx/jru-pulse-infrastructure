#Elastic Container Registry

resource "aws_ecr_repository" "python_api" {

    name               = "jru-pulse-python-api"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
}


resource "aws_ecr_repository" "web_app" {
    name               = "jru-pulse-web-app"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
      scan_on_push = true
    }

}