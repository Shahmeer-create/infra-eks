# ---------------------------------------------------------------------------
# EKS Cluster + Managed Node Group
# ---------------------------------------------------------------------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.name_prefix}-cluster"
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  enable_irsa = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = aws_iam_role.ebs_csi.arn
    }
  }

  eks_managed_node_groups = {
    bootstrap = {
      name           = "${local.name_prefix}-bootstrap"
      instance_types = [var.node_instance_type]
      min_size       = var.node_min_count
      max_size       = var.node_max_count
      desired_size   = var.node_desired_count
      subnet_ids     = aws_subnet.private[*].id

      labels = {
        role = "bootstrap"
      }

      tags = {
        Name                     = "${local.name_prefix}-bootstrap-node"
        "karpenter.sh/discovery" = "${local.name_prefix}-cluster"
      }
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Name                     = "${local.name_prefix}-cluster"
    "karpenter.sh/discovery" = "${local.name_prefix}-cluster"
  }
}

# ---------------------------------------------------------------------------
# EBS CSI Driver IAM Role
# ---------------------------------------------------------------------------

resource "aws_iam_role" "ebs_csi" {
  name = "${local.name_prefix}-ebs-csi-role"

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
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
