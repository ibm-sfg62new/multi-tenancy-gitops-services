# (C) Copyright 2021 Syncsort Incorporated. All rights reserved.

{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)

_sch-chart-config.tpl is a config file for the chart to specify additional 
values and/or override values defined in the sch/_config.tpl file.
 
*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "documentSvc.sch.chart.config.values" -}}
sch:
  chart:
    appName: "document-service"
    components:
      documentSvcApp: 
        name: "document-service"
      appInstance:
        name: "document"
      configmap:
        name: "app-config"
      preinstallJob:
        name: "preinstall-job"
      dashboard:
        name: "grafana"
      defaultNetworkPolicy:
        name: "default-network-policy"
      appLogsPVC:
        name: {{ .Values.appLogsPVC.name | default "logs" }}
    labelType: "prefixed"
    config:
        ciphers: "SSL_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,SSL_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,SSL_ECDHE_RSA_WITH_AES_256_GCM_SHA384,SSL_ECDHE_RSA_WITH_AES_128_GCM_SHA256,SSL_DHE_RSA_WITH_AES_256_GCM_SHA384,SSL_DHE_DSS_WITH_AES_256_GCM_SHA384,SSL_DHE_RSA_WITH_AES_128_GCM_SHA256,SSL_DHE_DSS_WITH_AES_128_GCM_SHA256,SSL_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,SSL_ECDHE_RSA_WITH_AES_256_CBC_SHA384,SSL_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,SSL_ECDHE_RSA_WITH_AES_128_CBC_SHA256,SSL_DHE_RSA_WITH_AES_256_CBC_SHA256,SSL_DHE_DSS_WITH_AES_256_CBC_SHA256,SSL_DHE_RSA_WITH_AES_128_CBC_SHA256,SSL_DHE_DSS_WITH_AES_128_CBC_SHA256,SSL_ECDH_ECDSA_WITH_AES_256_GCM_SHA384,SSL_ECDH_RSA_WITH_AES_256_GCM_SHA384,SSL_ECDH_ECDSA_WITH_AES_128_GCM_SHA256,SSL_ECDH_RSA_WITH_AES_128_GCM_SHA256,SSL_ECDH_ECDSA_WITH_AES_256_CBC_SHA384,SSL_ECDH_RSA_WITH_AES_256_CBC_SHA384,SSL_ECDH_ECDSA_WITH_AES_128_CBC_SHA256,SSL_ECDH_RSA_WITH_AES_128_CBC_SHA256,SSL_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,SSL_ECDHE_RSA_WITH_AES_256_CBC_SHA,SSL_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,SSL_ECDHE_RSA_WITH_AES_128_CBC_SHA,SSL_DHE_RSA_WITH_AES_256_CBC_SHA,SSL_DHE_DSS_WITH_AES_256_CBC_SHA,SSL_DHE_RSA_WITH_AES_128_CBC_SHA,SSL_DHE_DSS_WITH_AES_128_CBC_SHA,SSL_ECDH_ECDSA_WITH_AES_256_CBC_SHA,SSL_ECDH_RSA_WITH_AES_256_CBC_SHA,SSL_ECDH_ECDSA_WITH_AES_128_CBC_SHA,SSL_ECDH_RSA_WITH_AES_128_CBC_SHA,SSL_RSA_WITH_AES_256_GCM_SHA384,SSL_RSA_WITH_AES_128_GCM_SHA2562,SSL_RSA_WITH_AES_256_CBC_SHA256,SSL_RSA_WITH_AES_128_CBC_SHA256,SSL_RSA_WITH_AES_256_CBC_SHA,SSL_RSA_WITH_AES_128_CBC_SHA,TLS_AES_128_GCM_SHA256,TLS_AES_256_GCM_SHA384,TLS_EMPTY_RENEGOTIATION_INFO_SCSV"
    document:
      ingress:
        nginx.ingress.kubernetes.io/rewrite-target: /
        nginx.ingress.kubernetes.io/secure-backends: "true"
      metering:
        productID: {{ template "documentSvc.metering.productId" . }}
        productName: {{ template "documentSvc.metering.productName" . }}
        productVersion: {{ template "documentSvc.metering.productVersion" . }}
        productMetric: {{ template "documentSvc.metering.productMetric" . }}
      nonMetering:
        nonChargeableProductMetric: "FREE"
      nodeAffinity:
        nodeAffinityRequiredDuringScheduling:
          operator: In
          values:
          - amd64
          - ppc64le
        nodeAffinityPreferredDuringScheduling:
          amd64:
            weight: 3
            operator: In
            key: beta.kubernetes.io/arch
      spec:
        serviceAccountName: my-service-account
      podSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
          allowPrivilegeEscalation: false
          {{- if .Values.security.runAsUser }}
          runAsUser: {{ .Values.security.runAsUser }}
          {{- end }}
          capabilities:
            drop:
            - ALL
      specSecurityContext:
        hostNetwork: false
        hostPID: false
        hostIPC: false
        securityContext:
          runAsNonRoot: true
          {{- if .Values.security.runAsUser }}
          runAsUser: {{ .Values.security.runAsUser }}
          {{- end }}
          {{- if .Values.security.runAsGroup }}
          runAsGroup: {{ .Values.security.runAsGroup }}
          {{- end }}
          {{- if .Values.security.fsGroup }}
          fsGroup: {{ .Values.security.fsGroup }}
          {{- end }}
          {{- if .Values.security.supplementalGroups }}
          supplementalGroups: {{ .Values.security.supplementalGroups }}
          {{- end }}
      helmTestPodSecurityContext:
        securityContext:
          privileged: false
          readOnlyRootFilesystem: false
        allowPrivilegeEscalation: false
        capabilities:
          drop:
          - ALL
{{- end -}}
