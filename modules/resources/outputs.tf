output "namespace" {
  description = "The name (`metadata.name`) of the Kubernetes namespace"
  value       = var.k8s_namespace
}

output "svc" {
  description = "Local Kubernetes service FQDNs"
  value = {
    grafana    = local.grafana_svc
    loki       = local.loki_svc
    prometheus = local.prom_svc
  }
}

output "release" {
  description = "Helm releases"
  value = {
    metrics_server = local.release_metrics_server
    loki           = local.release_loki
    log_aggregator = local.release_aggregator
    prometheus     = local.release_prometheus
  }
}
