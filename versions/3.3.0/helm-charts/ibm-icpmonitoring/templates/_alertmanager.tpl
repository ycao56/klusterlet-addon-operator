{{/*
  Licensed Materials - Property of IBM
  5737-E67
  @ Copyright IBM Corporation 2016, 2019. All Rights Reserved.
  US Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
*/}}

{{/* Alertmanager Configuration Files */}}
{{- define "alermanagerConfig" }}
  global:
  receivers:
    - name: default-receiver
  route:
    group_wait: 10s
    group_interval: 5m
    receiver: default-receiver
    repeat_interval: 3h
{{- end }}
