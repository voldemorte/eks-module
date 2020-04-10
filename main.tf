module "eks_cluster" {
  source                               = "./eks-cluster"
  cluster_name                         = var.cluster_name
  cluster_iam_role_name                = var.cluster_iam_role_name
  iam_path                             = var.iam_path
  k8s_version                          = var.k8s_version
  vpc_id                               = var.vpc_id
  vpc_subnets                          = var.vpc_subnets
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  map_accounts                         = var.map_accounts
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  worker_groups                        = var.worker_groups
  workers_assume_role_name             = var.workers_assume_role_name
  workers_role_name                    = var.workers_role_name
}
