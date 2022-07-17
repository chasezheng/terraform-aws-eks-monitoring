grafana:
  serviceAccount:
    create: true
    name: ${grafana_service_account_name}
    annotations:
      eks.amazonaws.com/role-arn: ${grafana_iam_role_arn}

  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 10
    metrics:
    - type: Resource
      resource:
        name: cpu
        targetAverageUtilization: 60
    - type: Resource
      resource:
        name: memory
        targetAverageUtilization: 60

  persistence:
    enabled: true
    type: pvc
    existingClaim: ${grafana_pvc_claim}

  plugins:
    - grafana-piechart-panel
    - grafana-kubernetes-app

  datasources:
    "datasources.yaml":
      apiVersion: 1
      datasources:
        - name: Prometheus
          type: prometheus
          url: http://${prom_svc}
          access: proxy
          isDefault: false
          basicAuth: false
          withCredentials: false
          editable: false
        - name: Loki
          type: loki
          url: http://${loki_svc}
          isDefault: false
          basicAuth: false
          withCredentials: false
          editable: false
        - name: CloudWatch
          type: cloudwatch
          isDefault: false
          access: proxy
          uid: cloudwatch
          editable: false
          jsonData:
            authType: default
            defaultRegion: ${aws_region}

