# Secrets entry in Secrets manager
 resource "aws_secretsmanager_secret" "db_credentials" {

    name = "${var.project_name}-db-secrets-v1"
    description = "RDS connection details for JRU-PULSE"

    recovery_window_in_days = 0 
 }

resource "aws_secretsmanager_secret_version" "db_credentials_val" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username             = "admin"
    password             = var.db_password
    host                 = aws_db_instance.main.address
    db_name              = "jru_pulse"

    google_client_id     = var.google_client_id
    google_client_secret = var.google_client_secret
    google_redirect_uri  = "https://dnzjwkw4fgfzp.cloudfront.net/callback.php"

    mail_host            = "smtp.hostinger.com"
    mail_port            = "465"
    mail_username        = "noreply@jrupulse.com"
    mail_password        = var.mail_password
  })
}