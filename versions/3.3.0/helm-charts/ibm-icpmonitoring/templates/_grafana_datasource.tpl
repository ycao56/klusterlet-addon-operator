{{/*
  Licensed Materials - Property of IBM
   IBM Confidential
   OCO Source Materials
   (C) Copyright IBM Corporation 2016, 2019 All Rights Reserved
   The source code for this program is not published or otherwise divested of its trade secrets, irrespective of what has been deposited with the U.S. Copyright Office.
*/}}

{{/* Grafana Datasource Configuration Files */}}
{{- define "grafanaDatasourceConfig" }}
datasource.yaml: |-
    apiVersion: 1
    datasources:
    - name: prometheus
      type: prometheus
      isDefault: true
      editable: false
    {{- if .Values.tls.enabled }}
      access: proxy
      url: https://{{ template "prometheus.fullname" . }}:{{ .Values.prometheus.port }}
      jsonData:
         tlsAuth: true
         tlsAuthWithCACert: true
      secureJsonData:
        tlsCACert: "CA_CONTENT"
        tlsClientCert: "CERT_CONTENT"
        tlsClientKey: "KEY_CONTENT"
    {{- else }}
      access: proxy
      url: http://{{ template "prometheus.fullname" . }}:{{ .Values.prometheus.port }}   
    {{- end }}
{{- end }}