variable "oidc_url" {
  type        = string
  description = "OpenID Connect (OIDC) Identity Provider associated with the Kubernetes cluster"
}

variable "oidc_arn" {
  type = string
}

variable "k8s_namespace" {
  type = string
}

variable "loki_k8s_sa_name" {
  type        = string
  description = "Name of the Kubernetes service account for Loki components"
  default     = "loki"
}

variable "loki_storage_s3_bucket_arn" {
  type = string
}

variable "loki_storage_kms_key_arn" {
  type        = string
  description = "(Optional) ARN of the KMS key used for S3 encryption"
}

variable "grafana_k8s_sa_name" {
  type        = string
  description = "Name of the Kubernetes service account for Grafana"
  default     = "grafana"
}
