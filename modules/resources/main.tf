data "aws_region" "current" {}

locals {
  prom_svc_port = "80"
  prom_svc      = "kube-prometheus-stack-prometheus.${var.k8s_namespace}:${local.prom_svc_port}"
  loki_svc      = var.loki_mode == "distributed" ? "loki-distributed-gateway.${var.k8s_namespace}" : "loki.${var.k8s_namespace}:3100"
  grafana_svc   = "kube-prometheus-stack-grafana.${var.k8s_namespace}"
}

resource "helm_release" "metrics_server" {
  count      = var.metrics_server_enabled ? 1 : 0
  name       = var.helm_release_name_metrics_server
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = var.k8s_namespace
  version    = var.chart_version_metrics_server

  recreate_pods     = var.helm_recreate_pods
  atomic            = var.helm_atomic_creation
  cleanup_on_fail   = var.helm_cleanup_on_fail
  wait              = var.helm_wait_for_completion
  wait_for_jobs     = var.helm_wait_for_jobs
  timeout           = var.helm_timeout_seconds
  max_history       = var.helm_max_history
  verify            = var.helm_verify
  keyring           = var.helm_keyring
  reuse_values      = var.helm_reuse_values
  reset_values      = var.helm_reset_values
  force_update      = var.helm_force_update
  replace           = var.helm_replace
  create_namespace  = var.helm_create_namespace
  dependency_update = var.helm_dependency_update
  skip_crds         = var.helm_skip_crds

  dynamic "set" {
    for_each = var.helm_values_metrics_server
    content {
      name  = set.key
      value = set.value
      type  = "auto"
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "grafana_pvc" {
  metadata {
    generate_name = "kube-prometheus-stack-grafana"
    namespace     = var.k8s_namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
  wait_until_bound = false
}

resource "helm_release" "prometheus" {
  depends_on = [
    helm_release.metrics_server,
  ]
  name       = var.helm_release_name_prometheus
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.k8s_namespace
  version    = var.chart_version_prometheus

  recreate_pods     = var.helm_recreate_pods
  atomic            = var.helm_atomic_creation
  cleanup_on_fail   = var.helm_cleanup_on_fail
  wait              = var.helm_wait_for_completion
  wait_for_jobs     = var.helm_wait_for_jobs
  timeout           = var.helm_timeout_seconds
  max_history       = var.helm_max_history
  verify            = var.helm_verify
  keyring           = var.helm_keyring
  reuse_values      = var.helm_reuse_values
  reset_values      = var.helm_reset_values
  force_update      = var.helm_force_update
  replace           = var.helm_replace
  create_namespace  = var.helm_create_namespace
  dependency_update = var.helm_dependency_update
  skip_crds         = var.helm_skip_crds

  values = [
    templatefile("${path.module}/helm-values/kube-prometheus-stack.tpl", {
      aws_region                   = data.aws_region.current.name
      prom_svc                     = local.prom_svc
      loki_svc                     = local.loki_svc
      grafana_service_account_name = var.grafana_service_account_name
      grafana_iam_role_arn         = var.grafana_iam_role_arn
      grafana_pvc_claim            = kubernetes_persistent_volume_claim_v1.grafana_pvc.metadata[0].name
    })
  ]

  set {
    name  = "prometheus.service.port"
    value = local.prom_svc_port
  }

  dynamic "set" {
    for_each = var.helm_values_prometheus
    content {
      name  = set.key
      value = set.value
      type  = "auto"
    }
  }

  dynamic "set" {
    for_each = var.helm_values_grafana
    content {
      name  = "grafana.${set.key}"
      value = set.value
      type  = "auto"
    }
  }
}

resource "helm_release" "loki" {
  count      = var.loki_mode == "single" ? 1 : 0
  name       = coalesce(var.helm_release_name_loki, "loki")
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = var.k8s_namespace
  version    = var.chart_version_loki

  recreate_pods     = var.helm_recreate_pods
  atomic            = var.helm_atomic_creation
  cleanup_on_fail   = var.helm_cleanup_on_fail
  wait              = var.helm_wait_for_completion
  wait_for_jobs     = var.helm_wait_for_jobs
  timeout           = var.helm_timeout_seconds
  max_history       = var.helm_max_history
  verify            = var.helm_verify
  keyring           = var.helm_keyring
  reuse_values      = var.helm_reuse_values
  reset_values      = var.helm_reset_values
  force_update      = var.helm_force_update
  replace           = var.helm_replace
  create_namespace  = var.helm_create_namespace
  dependency_update = var.helm_dependency_update
  skip_crds         = var.helm_skip_crds

  values = [
    file("${path.module}/helm-values/loki.yml")
  ]

  dynamic "set" {
    for_each = var.helm_values_loki
    content {
      name  = set.key
      value = set.value
      type  = "auto"
    }
  }
}

resource "helm_release" "loki_distributed" {
  count      = var.loki_mode == "distributed" ? 1 : 0
  name       = coalesce(var.helm_release_name_loki, "loki-distributed")
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-distributed"
  namespace  = var.k8s_namespace
  version    = var.chart_version_loki_distributed

  recreate_pods     = var.helm_recreate_pods
  atomic            = var.helm_atomic_creation
  cleanup_on_fail   = var.helm_cleanup_on_fail
  wait              = var.helm_wait_for_completion
  wait_for_jobs     = var.helm_wait_for_jobs
  timeout           = var.helm_timeout_seconds
  max_history       = var.helm_max_history
  verify            = var.helm_verify
  keyring           = var.helm_keyring
  reuse_values      = var.helm_reuse_values
  reset_values      = var.helm_reset_values
  force_update      = var.helm_force_update
  replace           = var.helm_replace
  create_namespace  = var.helm_create_namespace
  dependency_update = var.helm_dependency_update
  skip_crds         = var.helm_skip_crds

  values = [
    templatefile("${path.module}/helm-values/loki-distributed.yml.tpl", {
      aws_region                          = data.aws_region.current.name
      bucket_name                         = var.loki_storage_s3_bucket_name
      loki_iam_role_arn                   = var.loki_iam_role_arn
      loki_service_account_name           = var.loki_service_account_name
      loki_compactor_iam_role_arn         = var.loki_iam_role_arn
      loki_compactor_service_account_name = var.loki_service_account_name
    })
  ]
  dynamic "set" {
    for_each = var.helm_values_loki_distributed
    content {
      name  = set.key
      value = set.value
      type  = "auto"
    }
  }
}

resource "helm_release" "fluent_bit" {
  count      = var.loki_aggregator == "fluent-bit" ? 1 : 0
  name       = var.helm_release_name_fluent_bit
  repository = "https://grafana.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = var.k8s_namespace
  version    = var.chart_version_fluent_bit

  recreate_pods     = var.helm_recreate_pods
  atomic            = var.helm_atomic_creation
  cleanup_on_fail   = var.helm_cleanup_on_fail
  wait              = var.helm_wait_for_completion
  wait_for_jobs     = var.helm_wait_for_jobs
  timeout           = var.helm_timeout_seconds
  max_history       = var.helm_max_history
  verify            = var.helm_verify
  keyring           = var.helm_keyring
  reuse_values      = var.helm_reuse_values
  reset_values      = var.helm_reset_values
  force_update      = var.helm_force_update
  replace           = var.helm_replace
  create_namespace  = var.helm_create_namespace
  dependency_update = var.helm_dependency_update
  skip_crds         = var.helm_skip_crds

  values = [
    templatefile("${path.module}/helm-values/fluent-bit.yml.tpl", {
      loki_svc = replace(local.loki_svc, ":3100", "")
    })
  ]

  dynamic "set" {
    for_each = var.helm_values_fluent_bit
    content {
      name  = set.key
      value = set.value
      type  = "auto"
    }
  }
}

resource "helm_release" "promtail" {
  count      = var.loki_aggregator == "promtail" ? 1 : 0
  name       = var.helm_release_name_promtail
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  namespace  = var.k8s_namespace
  version    = var.chart_version_promtail

  recreate_pods     = var.helm_recreate_pods
  atomic            = var.helm_atomic_creation
  cleanup_on_fail   = var.helm_cleanup_on_fail
  wait              = var.helm_wait_for_completion
  wait_for_jobs     = var.helm_wait_for_jobs
  timeout           = var.helm_timeout_seconds
  max_history       = var.helm_max_history
  verify            = var.helm_verify
  keyring           = var.helm_keyring
  reuse_values      = var.helm_reuse_values
  reset_values      = var.helm_reset_values
  force_update      = var.helm_force_update
  replace           = var.helm_replace
  create_namespace  = var.helm_create_namespace
  dependency_update = var.helm_dependency_update
  skip_crds         = var.helm_skip_crds

  values = [
    templatefile("${path.module}/helm-values/promtail.yml.tpl", {
      loki_address = "http://${local.loki_svc}/loki/api/v1/push"
    })
  ]

  dynamic "set" {
    for_each = var.helm_values_promtail
    content {
      name  = set.key
      value = set.value
      type  = "auto"
    }
  }
}

locals {
  release_metrics_server = var.metrics_server_enabled ? helm_release.metrics_server[0] : null
  release_prometheus     = helm_release.prometheus
  release_loki           = (var.loki_mode == "distributed" ? helm_release.loki_distributed : helm_release.loki)
  release_aggregator     = (var.loki_aggregator == "promtail" ? helm_release.promtail : helm_release.fluent_bit)
}
