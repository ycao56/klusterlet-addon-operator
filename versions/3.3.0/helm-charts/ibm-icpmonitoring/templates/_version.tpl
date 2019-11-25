{{/*
  Licensed Materials - Property of IBM
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
