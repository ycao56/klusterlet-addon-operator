{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mongodb-replicaset.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mongodb-replicaset.fullname" -}}
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
{{- define "mongodb-replicaset.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name for the admin secret.
*/}}
{{- define "mongodb-replicaset.adminSecret" -}}
    {{- if .Values.auth.existingAdminSecret -}}
        {{- .Values.auth.existingAdminSecret -}}
    {{- else -}}
        {{- template "mongodb-replicaset.fullname" . -}}-admin
    {{- end -}}
{{- end -}}

{{/*
Create a random string if the supplied key does not exist
*/}}
{{- define "mongodb-replicaset.adminPassword" -}}
    {{- if .Values.auth.adminPassword -}}
        {{- .Values.auth.adminPassword -}}
    {{- else -}}
        {{- randAlphaNum 10 -}}
    {{- end -}}
{{- end -}}

{{/*
Create the name for the key secret.
*/}}
{{- define "mongodb-replicaset.keySecret" -}}
    {{- if .Values.auth.existingKeySecret -}}
        {{- .Values.auth.existingKeySecret -}}
    {{- else -}}
        {{- template "mongodb-replicaset.fullname" . -}}-keyfile
    {{- end -}}
{{- end -}}

{{/*
Create the name for the ca cert.
*/}}
{{- define "mongodb-replicaset.casecret" -}}
    {{- if .Values.tls.casecret -}}
        {{- .Values.tls.casecret -}}
    {{- else -}}
        {{- template "mongodb-replicaset.fullname" . -}}-ca
    {{- end -}}
{{- end -}}
{{/*
Create the name for the client cert.
*/}}
{{- define "mongodb-replicaset.clientcertsecret" -}}
    {{- if .Values.tls.clientsecret -}}
        {{- .Values.tls.clientsecret -}}
    {{- else -}}
        {{- template "mongodb-replicaset.fullname" . -}}-client-cert
    {{- end -}}
{{- end -}}

{{- define "mongodb-replicaset.metricsSecret" -}}
    {{- if .Values.auth.existingMetricsSecret -}}
        {{- .Values.auth.existingMetricsSecret -}}
    {{- else -}}
        {{- template "mongodb-replicaset.fullname" . -}}-metrics
    {{- end -}}
{{- end -}}
