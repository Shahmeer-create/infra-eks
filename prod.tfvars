# Prod environment
project_name       = "myapp"
environment        = "prod"
aws_region         = "us-east-1"

# Networking
vpc_cidr           = "10.2.0.0/16"

# EKS
kubernetes_version = "1.30"
node_instance_type = "t3.large"
node_desired_count = 2
node_min_count     = 2
node_max_count     = 5

# Karpenter
karpenter_instance_types = ["t3.large", "t3.xlarge", "t3a.large", "t3a.xlarge"]

# App
app_replicas     = 2
app_min_replicas = 2
app_max_replicas = 10
container_port   = 3000

# Database
db_name         = "myapp"
db_storage_size = "20Gi"

# GitHub
github_repo     = "Shahmeer-create/infra-eks"
github_app_repo = "Shahmeer-create/my-app"
github_branch   = "main"

# HTTPS
enable_https    = true
certificate_arn = ""
