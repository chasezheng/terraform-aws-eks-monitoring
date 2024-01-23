prometheus:
  prometheusSpec:
    ruleSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    probeSelectorNilUsesHelmValues: false
    serviceMonitorSelectorNilUsesHelmValues: false

thanosRuler:
  thanosRulerSpec:
    ruleSelectorNilUsesHelmValues: false

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
  imageRenderer:
    enabled:  true
    revisionHistoryLimit: 2
    networkPolicy:
      limitIngress: false
    image:
      tag: "3.9.0"
      pullPolicy: "IfNotPresent"
  sidecar:
    dashboards:
      enabled: true
      searchNamespace: "ALL"
    datasources:
      enabled: true
      searchNamespace: "ALL"
    plugins:
      enabled: true
      searchNamespace: "ALL"
    notifiers:
      enabled: true
      searchNamespace: "ALL"