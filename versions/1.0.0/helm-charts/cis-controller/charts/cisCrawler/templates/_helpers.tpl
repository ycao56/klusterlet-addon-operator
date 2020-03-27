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