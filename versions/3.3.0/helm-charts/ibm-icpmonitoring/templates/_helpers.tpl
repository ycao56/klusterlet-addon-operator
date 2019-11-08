{{/* vim: set filetype=mustache: */}}

{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2019. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{- /*
"sch.version" contains the version information and tillerVersion constraint
for this version of the Shared Configurable Helpers.
*/ -}}
{{- define "sch.version" -}}
version: "1.2.0"
tillerVersion: ">=2.7.0"
{{- end -}}


{{/*
Create a default fully qualified app name for monitoring.
*/}}
{{- define "monitoring.fullname" -}}
{{- if .Values.monitoringFullnameOverride -}}
{{- .Values.monitoringFullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "monitoring" .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for prometheus.
*/}}
{{- define "prometheus.fullname" -}}
{{- if .Values.prometheusFullnameOverride -}}
{{- .Values.prometheusFullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "prometheus" .Values.prometheusNameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name for grafana.
*/}}
{{- define "grafana.fullname" -}}
{{- if .Values.grafanaFullnameOverride -}}
{{- .Values.grafanaFullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "grafana" .Values.grafanaNameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a user name for grafana.
*/}}
{{- define "grafana.user" -}}
{{- $name := default "admin" .Values.grafana.user -}}
{{- printf $name | b64enc -}}
{{- end -}}

{{/*
Create a password for grafana.
*/}}
{{- define "grafana.password" -}}
{{- $defaultName := "admin" -}}
{{- $name := default $defaultName .Values.grafana.password -}}
{{- printf $name | b64enc -}}
{{- end -}}

{{/*
Monitoring stack tolerations and affinity.
*/}}
{{- define "monitoring.affinity" -}}
{{- if eq .Values.mode "managed" }}
tolerations:
- key: "dedicated"
  operator: "Exists"
  effect: "NoSchedule"
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: management
          operator: In
          values:
          - "true"
{{- end }}
{{- end -}}

{{- define "router.probes" -}}
    {{- $params := . -}}
    {{- $clusterDomain := first $params -}}

readinessProbe:
  exec:
    command:
    - sh
    - -c
    - "wget --spider --no-check-certificate -S 'https://platform-identity-provider.kube-system.svc.{{- $clusterDomain -}}:4300/v1/info'"
  initialDelaySeconds: 10
  periodSeconds: 10
livenessProbe:
  exec:
    command:
    - sh
    - -c
    - "wget --spider --no-check-certificate -S 'https://platform-identity-provider.kube-system.svc.{{- $clusterDomain -}}:4300/v1/info'"
  initialDelaySeconds: 30
  periodSeconds: 20
{{- end -}}

{{- define "router.nginx.config" -}}
    {{- $params := . -}}
    {{- $parmLenth := len $params -}}
    {{- $list := first $params -}}
    {{- $port := (index $params 0) -}}
    {{- $listen := (index $params 1) -}}
    {{- $caCert := (index $params 2) -}}
    {{- $ssl_ciphers := (index $params 3) -}}
        error_log stderr notice;

        events {
            worker_connections 1024;
        }

        http {
            access_log off;

            default_type application/octet-stream;
            sendfile on;
            keepalive_timeout 65;
            server_tokens off;
            more_set_headers "Server: ";

            # Without this, cosocket-based code in worker
            # initialization cannot resolve localhost.

            upstream metrics {
                server 127.0.0.1:{{- $port -}};
            }
            proxy_cache_path /tmp/nginx-mesos-cache levels=1:2 keys_zone=mesos:1m inactive=10m;

            server {
                listen {{ $listen }} ssl default_server;
                ssl_certificate server.crt;
                ssl_certificate_key server.key;
                ssl_client_certificate /opt/ibm/router/caCerts/{{- $caCert -}};
                ssl_verify_client on;
                ssl_protocols TLSv1.2;
                # Ref: https://github.com/cloudflare/sslconfig/blob/master/conf
                # Modulo ChaCha20 cipher.
                ssl_ciphers {{ $ssl_ciphers -}};
                ssl_prefer_server_ciphers on;

                server_name dcos.*;
                root /opt/ibm/router/nginx/html;

                location / {
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header Host $http_host;
                  proxy_pass http://metrics/;
                }

                location /index.html {
                    return 404;
                }                
            }

          {{- if eq $parmLenth 5 }}
          {{- $healthyPort := (index $params 4) }}
            server {
                listen {{ $healthyPort }} ssl default_server;
                ssl_certificate server.crt;
                ssl_certificate_key server.key;
                ssl_client_certificate /opt/ibm/router/caCerts/{{- $caCert -}};
                ssl_verify_client off;
                ssl_protocols TLSv1.2;
                # Ref: https://github.com/cloudflare/sslconfig/blob/master/conf
                # Modulo ChaCha20 cipher.
                ssl_ciphers {{ $ssl_ciphers -}};
                ssl_prefer_server_ciphers on;

                server_name dcos.*;
                root /opt/ibm/router/nginx/html;

                location /healthy {
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                  proxy_set_header Host $http_host;
                  proxy_pass http://metrics/healthy;
                }
            }
          {{- end }}
        }
{{- end -}}
