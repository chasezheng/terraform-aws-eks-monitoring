resource "aws_iam_role" "grafana" {
  name = "${var.grafana_k8s_sa_name}-${random_string.name-suffix.result}"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_arn
      }
      Condition = {
        StringEquals = {
          format("%s:sub", var.oidc_url) = "system:serviceaccount:${var.k8s_namespace}:${var.grafana_k8s_sa_name}"
        }
      }
    }]
    Version = "2012-10-17"
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy" "grafana_permissions" {
  name   = "${var.grafana_k8s_sa_name}-${random_string.name-suffix.result}"
  role   = aws_iam_role.grafana.id
  policy = file("${path.module}/policies/grafana-permissions.json")
}
