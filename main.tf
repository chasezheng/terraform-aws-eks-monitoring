resource "random_id" "id" {
  byte_length = 8
}

locals {
  s3_bucket_name_norm = var.loki_storage_s3_bucket_name == "" ? null : var.loki_storage_s3_bucket_name
  s3_bucket_name_pre  = var.create_loki_storage_id_suffix ? (local.s3_bucket_name_norm != null ? "${local.s3_bucket_name_norm}-${random_id.id.hex}" : "loki-storage-${random_id.id.hex}") : local.s3_bucket_name_norm
}

module "log_storage" {
  count                           = var.create_loki_storage ? 1 : 0
  source                          = "./modules/storage"
  s3_force_destroy                = var.loki_storage_s3_force_destroy
  s3_bucket_name                  = (local.s3_bucket_name_pre == null ? "" : local.s3_bucket_name_pre)
  create_s3_bucket_id_suffix      = var.create_loki_storage_id_suffix
  create_kms_key                  = var.create_loki_storage_kms_key
  kms_key_arn                     = var.loki_storage_kms_key_arn
  kms_key_deletion_window_in_days = var.loki_storage_kms_key_deletion_window_in_days
  kms_key_enable_rotation         = var.loki_storage_kms_key_enable_rotation
  expiration_days                 = var.loki_storage_expiration_days
}

locals {
  s3_bucket_name = var.create_loki_storage ? module.log_storage[0].bucket.id : (local.s3_bucket_name_pre == null ? "" : local.s3_bucket_name_pre)
  kms_key_arn    = var.create_loki_storage_kms_key ? module.log_storage[0].encryption_key.arn : var.loki_storage_kms_key_arn
}

module "iam" {
  source                     = "./modules/iam"
  oidc_url                   = var.oidc_url
  oidc_arn                   = var.oidc_arn
  k8s_namespace              = var.k8s_namespace
  loki_k8s_sa_name           = var.loki_k8s_sa_name
  grafana_k8s_sa_name        = var.grafana_k8s_sa_name
  loki_storage_s3_bucket_arn = module.log_storage[0].bucket.arn
  loki_storage_kms_key_arn   = local.kms_key_arn
}

module "resources" {
  source                         = "./modules/resources"
  k8s_namespace                  = var.k8s_namespace
  metrics_server_enabled         = var.metrics_server_enabled
  loki_service_account_name      = var.loki_k8s_sa_name
  grafana_service_account_name   = var.grafana_k8s_sa_name
  loki_iam_role_arn              = module.iam.loki_role.arn
  grafana_iam_role_arn           = module.iam.grafana_role.arn
  loki_storage_s3_bucket_name    = local.s3_bucket_name
  chart_version_metrics_server   = var.chart_version_metrics_server
  chart_version_prometheus       = var.chart_version_prometheus
  chart_version_promtail         = var.chart_version_promtail
  chart_version_loki_distributed = var.chart_version_loki_distributed
  chart_version_loki             = var.chart_version_loki
  helm_values_grafana            = var.helm_values_grafana
  helm_values_loki               = var.helm_values_loki
  helm_values_loki_distributed   = var.helm_values_loki_distributed
  helm_values_promtail           = var.helm_values_promtail
  helm_values_prometheus         = var.helm_values_prometheus
  helm_values_metrics_server     = var.helm_values_metrics_server
}
