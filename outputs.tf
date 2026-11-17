# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "ecr_repository_url" {
  description = "ECR repository URL — use this in kubernetes/backend-deployment.yaml"
  value       = aws_ecr_repository.backend.repository_url
}

output "s3_photos_bucket" {
  description = "S3 photos bucket name — use this in kubernetes/backend-deployment.yaml"
  value       = aws_s3_bucket.photos.id
}

output "backend_app_role_arn" {
  description = "IRSA role ARN for backend pod — use in kubernetes/backend-deployment.yaml"
  value       = aws_iam_role.backend_app.arn
}

output "external_secrets_role_arn" {
  description = "IRSA role ARN for external-secrets — use in kubernetes/external-secret.yaml"
  value       = aws_iam_role.external_secrets.arn
}

output "karpenter_node_role_name" {
  description = "Karpenter node IAM role name — use in kubernetes/karpenter-nodeclass.yaml"
  value       = aws_iam_role.karpenter_node.name
}

output "db_secret_arn" {
  description = "Secrets Manager secret ARN for DB credentials"
  value       = aws_secretsmanager_secret.db.arn
  sensitive   = true
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs — use in kubernetes/ingress.yaml"
  value       = aws_subnet.public[*].id
}

output "alb_security_group_id" {
  description = "ALB security group ID — use in kubernetes/ingress.yaml"
  value       = aws_security_group.alb.id
}

output "kubectl_config_command" {
  description = "Run this to configure kubectl after apply"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "amplify_app_url" {
  description = "Amplify frontend URL"
  value       = "https://${var.github_branch}.${aws_amplify_app.frontend.default_domain}"
}

output "github_oidc_role_arn" {
  description = "Set as AWS_OIDC_ROLE_ARN in infra-eks GitHub repo"
  value       = aws_iam_role.github_oidc_infra.arn
}

output "github_oidc_app_role_arn" {
  description = "Set as AWS_OIDC_ROLE_ARN in my-app GitHub repo"
  value       = aws_iam_role.github_oidc_app.arn
}
