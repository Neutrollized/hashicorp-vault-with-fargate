#-----------------------
# AWS basic vars
#-----------------------
variable "region" {
  default = "ca-central-1"
}


#-------------------------
# ECR
#-------------------------
variable "ecr_name" {
  description = "Name of Elastic Container Registry repo."
  default     = "vault"
}


#-------------------------
# S3
#-------------------------
variable "s3_bucket_name" {
  description = "Name of S3 Storage Bucket used for Vault backend"
  default     = "vault-storage"
}


#-------------------------
# ECS
#-------------------------
variable "ecs_cluster_name" {
  description = "Name of ECS Cluster"
  default     = "vault-ecs-cluster"
}

variable "ecs_service_name" {
  default = "vault-ecs-service"
}


#-------------------------
# HashiCorp Vault
#-------------------------
variable "vault_version" {
  default = "1.11.4"
}
