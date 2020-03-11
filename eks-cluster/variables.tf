variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
}

variable "cluster_iam_role_name" {
  description = "IAM role name for the cluster. Only applicable if manage_cluster_iam_resources is set to false."
  type        = string
  default     = "EKSClusterRole"
}

variable "iam_path" {
  description = "If provided, all IAM roles will be created on this path."
  type        = string
  default     = "/eks/"
}

variable "k8s_version" {
  description = "Kubernetes version"
  default     = "1.14"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the cluster and workers will be deployed."
  type        = string
}

variable "vpc_subnets" {
  description = "A list of subnets to place the EKS cluster and workers within."
  type        = list(string)
}

variable "worker_groups" {
  description = "A list of Autoscaling groups with following attributes"
  type        = any
}

variable "workers_role_name" {
  description = "User defined workers role name."
  type        = string
  default     = "EKSWorkersRole"
}
