output "loki_role" {
  value = aws_iam_role.loki
}

output "grafana_role" {
  value = aws_iam_role.grafana
}