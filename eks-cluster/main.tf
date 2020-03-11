locals {
  worker_groups = [for worker_group in var.worker_groups :
    merge(worker_group,
      {
        tags = [
          {
            "key"                 = "k8s.io/cluster-autoscaler/enabled"
            "propagate_at_launch" = "false"
            "value"               = "true"
          },
          {
            "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
            "propagate_at_launch" = "false"
            "value"               = "true"
          },
        ]
      }
    )
  ]
}

## Set worker assumeRole policy
## Allows kube2iam to provision pods with iam roles.
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eks_worker_assume_role" {
  statement {
    sid = "1"
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks/*"
    ]
  }
}

resource "aws_iam_policy" "eks_worker_assume_role" {
  name        = "EKSWorkerAssumeRole"
  description = "Allow EKS workers to assume other roles"
  path        = var.iam_path
  policy      = data.aws_iam_policy_document.eks_worker_assume_role.json
}

###############################

module "eks" {
  source                               = "github.com/terraform-aws-modules/terraform-aws-eks?ref=v9.0.0"
  cluster_name                         = var.cluster_name
  cluster_version                      = var.k8s_version
  vpc_id                               = var.vpc_id
  subnets                              = var.vpc_subnets
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # IAM Roles
  iam_path              = var.iam_path
  cluster_iam_role_name = var.cluster_iam_role_name
  workers_role_name     = var.workers_role_name

  # Disable aws_auth_configmap
  manage_aws_auth = true

  # Enable IAM Role for Service Account
  # Ref - https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
  enable_irsa = true

  # Set worker IAM policies
  workers_additional_policies = [aws_iam_policy.eks_worker_assume_role.arn]

  # Define worker groups
  worker_groups = local.worker_groups

  write_kubeconfig = false

  # Cluster logging
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

}

## Ref - https://github.com/hashicorp/terraform/issues/1178#issuecomment-449158607
resource "null_resource" "dependency_setter" {
  depends_on = [
    module.eks.cluster_endpoint
  ]
}
