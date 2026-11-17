# ---------------------------------------------------------------------------
# Project
# ---------------------------------------------------------------------------

variable "project_name" {
  description = "Short name used as prefix for all resources"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Deployment environment: dev, staging, or prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

# ---------------------------------------------------------------------------
# EKS
# ---------------------------------------------------------------------------

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "node_instance_type" {
  description = "EC2 instance type for initial EKS managed node group"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_count" {
  description = "Desired number of nodes in initial node group"
  type        = number
  default     = 1
}

variable "node_min_count" {
  description = "Minimum number of nodes in initial node group"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum number of nodes in initial node group"
  type        = number
  default     = 3
}

# ---------------------------------------------------------------------------
# Karpenter
# ---------------------------------------------------------------------------

variable "karpenter_instance_types" {
  description = "Instance types Karpenter can provision"
  type        = list(string)
  default     = ["t3.medium", "t3.large", "t3a.medium", "t3a.large"]
}

# ---------------------------------------------------------------------------
# Application
# ---------------------------------------------------------------------------

variable "container_port" {
  description = "Port the backend container listens on"
  type        = number
  default     = 3000
}

variable "app_replicas" {
  description = "Initial number of backend pod replicas"
  type        = number
  default     = 1
}

variable "app_min_replicas" {
  description = "Minimum replicas for HPA"
  type        = number
  default     = 1
}

variable "app_max_replicas" {
  description = "Maximum replicas for HPA"
  type        = number
  default     = 5
}

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------

variable "db_name" {
  description = "MySQL database name"
  type        = string
  default     = "myapp"
}

variable "db_storage_size" {
  description = "PVC storage size for MySQL (Gi)"
  type        = string
  default     = "10Gi"
}

# ---------------------------------------------------------------------------
# GitHub / OIDC
# ---------------------------------------------------------------------------

variable "github_repo" {
  description = "GitHub repo for infra (owner/repo)"
  type        = string
  default     = "Shahmeer-create/infra-eks"
}

variable "github_app_repo" {
  description = "GitHub repo for app code (owner/repo)"
  type        = string
  default     = "Shahmeer-create/my-app"
}

variable "github_branch" {
  description = "Branch name"
  type        = string
  default     = "main"
}

# ---------------------------------------------------------------------------
# Amplify
# ---------------------------------------------------------------------------

variable "github_access_token" {
  description = "GitHub personal access token for Amplify"
  type        = string
  sensitive   = true
  default     = ""
}

# ---------------------------------------------------------------------------
# HTTPS
# ---------------------------------------------------------------------------

variable "enable_https" {
  description = "Enable HTTPS on ALB"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}
