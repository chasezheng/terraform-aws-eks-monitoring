variable "oidc_url" {
  type        = string
  description = "OpenID Connect (OIDC) Identity Provider associated with the Kubernetes cluster"
}

variable "oidc_arn" {
  type        = string
  description = "OpenID Connect (OIDC) Identity Provider associated with the Kubernetes cluster"
}

variable "k8s_namespace" {
  type        = string
  description = "Name of the Kubernetes namespace to which resources will be deployed"
}

variable "metrics_server_enabled" {
  type        = bool
  description = "Enable Metrics Server?"
  default     = true
}

variable "helm_values_metrics_server" {
  type    = map(string)
  default = {}
}

variable "helm_values_prometheus" {
  type    = map(string)
  default = {}
}

variable "helm_values_promtail" {
  type    = map(string)
  default = {}
}

variable "helm_values_loki_distributed" {
  type    = map(string)
  default = {}
}

variable "helm_values_grafana" {
  type    = map(string)
  default = {}
}

variable "helm_values_loki" {
  type    = map(string)
  default = {}
}

variable "loki_mode" {
  type        = string
  description = "Loki mode, must be either `single` or `distributed`"
  default     = "distributed"
  validation {
    condition     = can(regex("^single|distributed$", var.loki_mode))
    error_message = "Must be one of `single` or `distributed`."
  }
}


variable "create_loki_storage" {
  type        = bool
  description = "Create S3 bucket for Loki storage?"
  default     = false
}

variable "create_loki_storage_id_suffix" {
  type        = bool
  description = "Append a random identifier string suffix to the Loki storage S3 bucket name?"
  default     = false
}

variable "create_loki_storage_kms_key" {
  type        = bool
  description = "Create KMS key?"
  default     = true
}

variable "loki_storage_s3_bucket_name" {
  type        = string
  description = "Name of S3 bucket used for Loki storage"
  default     = ""
}

variable "loki_storage_s3_force_destroy" {
  type        = bool
  description = "Force destroy bucket when running `terraform destroy`?"
  default     = true
}

variable "loki_storage_kms_key_arn" {
  type        = string
  description = "(Optional) ARN of KMS key used to encrypt bucket objects; ignored if `create_kms_key` is set to `true`"
  default     = null
}

variable "loki_storage_kms_key_deletion_window_in_days" {
  type        = number
  description = "KMS key deletion window in days"
  default     = 30
}

variable "loki_storage_kms_key_enable_rotation" {
  type        = bool
  description = "Enable KMS key rotation?"
  default     = true
}

variable "loki_storage_expiration_days" {
  type        = number
  description = "Number of days to retain objects; `0` means never expire"
  default     = 90
}

variable "loki_k8s_sa_name" {
  type        = string
  description = "Name of the Kubernetes service account for Loki components"
  default     = "loki"
}

variable "grafana_k8s_sa_name" {
  type        = string
  description = "Name of the Kubernetes service account for Grafana"
  default     = "grafana"
}

## chart versions

variable "chart_version_metrics_server" {
  type        = string
  description = "Chart version"
  default     = "3.8.2"
}

variable "chart_version_prometheus" {
  type        = string
  description = "Chart version"
  default     = "39.11.0"
}

variable "chart_version_promtail" {
  type        = string
  description = "Chart version"
  default     = "6.3.0"
}

variable "chart_version_loki_distributed" {
  type        = string
  description = "Chart version"
  default     = "0.56.7"
}


variable "chart_version_loki" {
  type        = string
  description = "Chart version"
  default     = "3.0.3"
}

## end chart versions
