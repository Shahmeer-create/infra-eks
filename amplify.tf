# ---------------------------------------------------------------------------
# Amplify — Frontend (React/Vite)
# VITE_API_URL will be updated manually after ALB is created by ingress
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "amplify_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "amplify" {
  name               = "${local.name_prefix}-eks-amplify-role"
  assume_role_policy = data.aws_iam_policy_document.amplify_assume.json
}

resource "aws_iam_role_policy_attachment" "amplify" {
  role       = aws_iam_role.amplify.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

resource "aws_amplify_app" "frontend" {
  name                 = "${local.name_prefix}-eks-frontend"
  repository           = "https://github.com/${var.github_app_repo}"
  platform             = "WEB"
  iam_service_role_arn = aws_iam_role.amplify.arn
  access_token         = var.github_access_token

  build_spec = <<-EOT
    version: 1
    applications:
      - appRoot: frontend
        frontend:
          phases:
            preBuild:
              commands:
                - npm install
            build:
              commands:
                - npm run build
          artifacts:
            baseDirectory: dist
            files:
              - "**/*"
          cache:
            paths:
              - node_modules/**/*
  EOT

  # Set after ALB is created — update with: terraform apply after getting ALB DNS
  environment_variables = {
    VITE_API_URL = "https://backend.cloudstack.site"
  }

  enable_auto_branch_creation = false
  enable_branch_auto_deletion = true

  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|txt|svg|woff|woff2|ttf|map|json)$)([^.]+$)/>"
    target = "/index.html"
    status = "200"
  }

  tags = {
    Name = "${local.name_prefix}-eks-frontend"
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = var.github_branch
  stage       = "DEVELOPMENT"

  enable_auto_build           = true
  enable_pull_request_preview = true

  environment_variables = {
    VITE_API_URL = "https://backend.cloudstack.site"
  }

  tags = {
    Name = "${local.name_prefix}-eks-frontend-main"
  }
}
