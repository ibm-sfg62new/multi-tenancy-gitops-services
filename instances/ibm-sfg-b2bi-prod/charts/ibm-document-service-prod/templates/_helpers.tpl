# (C) Copyright 2021 Syncsort Incorporated. All rights reserved.

{{- /* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/ -}}
{{- define "documentSvc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "documentSvc.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "documentSvc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
{{- define "documentSvc.imagePullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.image.repository (printf "%s:%s" .Values.image.username .Values.image.password | b64enc) | b64enc -}}
{{- end -}}
*/}}

{{/*
Create productID, product name, version, productMetric, productChargedContainers for metering and licensing purpose.
*/}}
{{- define "documentSvc.metering.productName" -}}
{{ range ( .Files.Lines "product.info" ) -}}
{{- if regexMatch "^productName=.*" . -}}
{{- substr 12 (len .) . -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- define "documentSvc.metering.productId" -}}
{{ range ( .Files.Lines "product.info" ) -}}
{{- if regexMatch "^productId=.*" . -}}
{{- substr 10 (len .) . -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- define "documentSvc.metering.productVersion" -}}
{{ range ( .Files.Lines "product.info" ) -}}
{{- if regexMatch "^productVersion=.*" . -}}
{{- substr 15 (len .) . -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- define "documentSvc.metering.productMetric" -}}
{{ range ( .Files.Lines "product.info" ) -}}
{{- if regexMatch "^productMetric=.*" . -}}
{{- substr 14 (len .) . -}}
{{- end -}}
{{- end -}}
{{- end -}}