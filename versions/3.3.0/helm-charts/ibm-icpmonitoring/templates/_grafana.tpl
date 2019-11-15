{{/*
  Licensed Materials - Property of IBM
   IBM Confidential
   OCO Source Materials
   (C) Copyright IBM Corporation 2016, 2019 All Rights Reserved
   The source code for this program is not published or otherwise divested of its trade secrets, irrespective of what has been deposited with the U.S. Copyright Office.
*/}}

{{/* Grafana Configuration Files */}}
{{- define "grafanaConfig" }}
grafana.ini: |-
    [paths]
    data = /var/lib/grafana
    logs = /var/log/grafana
    plugins = /var/lib/grafana/plugins

    {{- if .Values.tls.enabled }}
    [server]
    protocol = https
    domain = {{ .Values.clusterAddress }}
    http_port = {{ .Values.clusterPort }}
    root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana
    cert_file = /opt/ibm/monitoring/certs/{{ .Values.tls.server.certFieldName }}
    cert_key = /opt/ibm/monitoring/certs/{{ .Values.tls.server.keyFieldName }}
    {{- end }}

    [users]
    default_theme = light

    [log]
    mode = console

    [auth]
    disable_login_form = true
    disable_signout_menu = true

    [auth.proxy]
    enabled = true
    header_name = X-WEBAUTH-USER
    header_property = username
    auto_sign_up = false
    whitelist =
    headers =

{{- end }}
