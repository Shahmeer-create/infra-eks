# ---------------------------------------------------------------------------
# IRSA — Backend app role for S3 access
# ---------------------------------------------------------------------------

resource "aws_iam_role" "backend_app" {
  name = "${local.name_prefix}-backend-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:${var.project_name}:backend-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "backend_app_s3" {
  name = "${local.name_prefix}-backend-s3-policy"
  role = aws_iam_role.backend_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = "${aws_s3_bucket.photos.arn}/photos/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:HeadBucket"]
        Resource = aws_s3_bucket.photos.arn
      }
    ]
  })
}
