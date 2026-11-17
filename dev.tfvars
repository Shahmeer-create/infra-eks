# Dev environment
project_name       = "myapp"
environment        = "dev"
aws_region         = "us-east-1"

# Networking
vpc_cidr           = "10.1.0.0/16"

# EKS
kubernetes_version = "1.31"
node_instance_type = "t3.medium"
node_desired_count = 1
node_min_count     = 1
node_max_count     = 3

# Karpenter
karpenter_instance_types = ["t3.medium", "t3.large", "t3a.medium"]

# App
app_replicas     = 1
app_min_replicas = 1
app_max_replicas = 5
container_port   = 3000

# Database
db_name         = "myapp"
db_storage_size = "10Gi"

# GitHub
github_repo     = "Shahmeer-create/infra-eks"
github_app_repo = "Shahmeer-create/my-app"
github_branch   = "main"

# HTTPS
enable_https    = true
certificate_arn = "arn:aws:acm:us-east-1:516027198635:certificate/052c0f32-3727-45cb-a3e8-f318f2e008fb"
