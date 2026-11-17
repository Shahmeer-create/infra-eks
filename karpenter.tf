# ---------------------------------------------------------------------------
# Karpenter — IAM roles + Helm install only
# NodePool and EC2NodeClass are in kubernetes/karpenter-nodepool.yaml
# ---------------------------------------------------------------------------

resource "aws_iam_role" "karpenter_controller" {
  name = "${local.name_prefix}-karpenter-controller"

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
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:karpenter"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "karpenter_controller" {
  name = "${local.name_prefix}-karpenter-policy"
  role = aws_iam_role.karpenter_controller.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:RunInstances", "ec2:CreateLaunchTemplate", "ec2:CreateFleet", "ec2:CreateTags", "ec2:DescribeImages", "ec2:DescribeInstances", "ec2:DescribeInstanceTypes", "ec2:DescribeInstanceTypeOfferings", "ec2:DescribeLaunchTemplates", "ec2:DescribeSecurityGroups", "ec2:DescribeSubnets", "ec2:DescribeSpotPriceHistory", "ec2:DescribeAvailabilityZones", "ec2:TerminateInstances", "ec2:DeleteLaunchTemplate"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole", "iam:CreateInstanceProfile", "iam:TagInstanceProfile", "iam:AddRoleToInstanceProfile", "iam:RemoveRoleFromInstanceProfile", "iam:DeleteInstanceProfile", "iam:GetInstanceProfile"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:DeleteMessage", "sqs:GetQueueUrl", "sqs:GetQueueAttributes", "sqs:ReceiveMessage"]
        Resource = [aws_sqs_queue.karpenter_interruption.arn]
      },
      {
        Effect   = "Allow"
        Action   = ["pricing:GetProducts", "ssm:GetParameter"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["eks:DescribeCluster", "eks:AccessKubernetesApi"]
        Resource = [module.eks.cluster_arn]
      }
    ]
  })
}

resource "aws_iam_role" "karpenter_node" {
  name = "${local.name_prefix}-karpenter-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ])
  role       = aws_iam_role.karpenter_node.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "karpenter_node" {
  name = "${local.name_prefix}-karpenter-node"
  role = aws_iam_role.karpenter_node.name
}

resource "aws_sqs_queue" "karpenter_interruption" {
  name                      = "${local.name_prefix}-karpenter-interruption"
  message_retention_seconds = 300
  tags = { Name = "${local.name_prefix}-karpenter-interruption" }
}

# Install Karpenter via Helm
resource "helm_release" "karpenter" {
  namespace        = "kube-system"
  create_namespace = false
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "0.37.0"
  wait             = false
  timeout          = 300
  skip_crds        = false

  lifecycle {
    ignore_changes = all
  }

  set {
    name  = "replicas"
    value = "1"
  }

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.interruptionQueue"
    value = aws_sqs_queue.karpenter_interruption.name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter_controller.arn
  }

  depends_on = [module.eks]
}
