output "state_bucket_name" {
  value = aws_s3_bucket.state.bucket
}

output "lock_table_name" {
  value = aws_dynamodb_table.locks.name
}

output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "next_steps" {
  value = <<-EOT
    Bootstrap complete. Next steps:
    1. Run: cd .. && tf init && tf apply
    2. After apply, set GitHub secrets in infra-eks and my-app repos
    3. Run: aws eks update-kubeconfig --region us-east-1 --name myapp-dev-cluster
  EOT
}
