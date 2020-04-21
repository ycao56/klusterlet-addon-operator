{{/*
Create a default fully qualified app name for cisController.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cisController.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
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
Create a default fully qualified app name for minio cleaner.
*/}}
{{- define "minioCleaner.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
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
Generate certificates for minio
*/}}
{{- define "cisController.gen-certs" -}}
{{- $altNames := list ( printf "%s.%s" (include "minio.fullname" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "minio.fullname" .) .Release.Namespace )  (printf "%s" (include "minio.fullname" .)) -}}
{{- $ca := genCA "cis-ctrl-ca" 365 -}}
{{- $cert := genSignedCert ( include "minio.fullname" . ) nil $altNames 365 $ca -}}
ca.crt: {{ $ca.Cert | b64enc }}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Create a default fully qualified app name for cisCrawler.
*/}}
{{- define "cisCrawler.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride "crawler" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if .Values.global.fullnameOverride -}}
{{- printf "%s-%s" .Values.global.fullnameOverride "crawler" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "cis-crawler" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for cisMasterCrawler.
*/}}
{{- define "cisCrawlerMaster.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride "crawler-master" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if .Values.global.fullnameOverride -}}
{{- printf "%s-%s" .Values.global.fullnameOverride "crawler-master" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "cis-crawler-master" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for cisWorkerCrawler.
*/}}
{{- define "cisCrawlerWorker.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride "crawler-worker" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if .Values.global.fullnameOverride -}}
{{- printf "%s-%s" .Values.global.fullnameOverride "crawler-worker" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "cis-crawler-worker" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for cisWorkerCrawler on OCP 3.11.
*/}}
{{- define "cisCrawlerCompute.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride "crawler-compute" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if .Values.global.fullnameOverride -}}
{{- printf "%s-%s" .Values.global.fullnameOverride "crawler-compute" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "cis-crawler-compute" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "drishti.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride "drishti" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if .Values.global.fullnameOverride -}}
{{- printf "%s-%s" .Values.global.fullnameOverride "drishti" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s"  .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "minio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "minio.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride "minio" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- if .Values.global.fullnameOverride -}}
{{- printf "%s-%s" .Values.global.fullnameOverride "minio" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
