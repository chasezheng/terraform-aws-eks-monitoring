resource "aws_iam_role" "loki" {
  name = "${var.loki_k8s_sa_name}-${random_string.name-suffix.result}"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_arn
      }
      Condition = {
        StringEquals = {
          format("%s:sub", var.oidc_url) = "system:serviceaccount:${var.k8s_namespace}:${var.loki_k8s_sa_name}"
        }
      }
    }]
    Version = "2012-10-17"
  })
  force_detach_policies = true
}

resource "aws_iam_role_policy" "loki_permissions" {
  name   = "${var.loki_k8s_sa_name}-${random_string.name-suffix.result}"
  role   = aws_iam_role.loki.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowListObjects",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "${var.loki_storage_s3_bucket_arn}"
        },
        {
            "Sid": "AllowObjectsCRUD",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "${var.loki_storage_s3_bucket_arn}/*"
        },
        {
            "Sid": "AllowUseKey",
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey",
                "kms:Decrypt"
            ],
            "Resource": "${var.loki_storage_kms_key_arn}"
        }
    ]
}
EOF
}
