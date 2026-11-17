# ---------------------------------------------------------------------------
# AWS Secrets Manager — DB credentials
# External Secrets Operator syncs this into a Kubernetes Secret
# ---------------------------------------------------------------------------

resource "random_password" "db" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "${local.name_prefix}/db/credentials"
  description             = "MySQL credentials for ${local.name_prefix} EKS app"
  recovery_window_in_days = 0

  tags = {
    Name = "${local.name_prefix}-db-secret"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.db.result
    host     = "mysql.${var.project_name}.svc.cluster.local"
    port     = "3306"
    dbname   = var.db_name
  })
}
