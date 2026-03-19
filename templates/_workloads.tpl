{{- define "helpers.workloads.envs" -}}
{{- $ctx := .context -}}
{{- $general := .general | default dict -}}
{{- $v := .value | default dict -}}
{{- if or $general.envsFromConfigmap $v.envsFromConfigmap $general.envsFromSecret $v.envsFromSecret $general.env $v.env -}}
env:
{{- with $general.envsFromConfigmap }}
{{ include "helpers.configmaps.includeEnv" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $v.envsFromConfigmap }}
{{ include "helpers.configmaps.includeEnv" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $general.envsFromSecret }}
{{ include "helpers.secrets.includeEnv" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $v.envsFromSecret }}
{{ include "helpers.secrets.includeEnv" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $general.env }}
{{ include "helpers.tplvalues.render" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $v.env }}
{{ include "helpers.tplvalues.render" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}

{{- define "helpers.workloads.envsFrom" -}}
{{- $ctx := .context -}}
{{- $general := .general | default dict -}}
{{- $v := .value | default dict -}}
{{- if or $general.envConfigmaps $v.envConfigmaps $general.envSecrets $v.envSecrets $general.envFrom $v.envFrom -}}
envFrom:
{{- with $general.envConfigmaps }}
{{ include "helpers.configmaps.includeEnvConfigmap" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $v.envConfigmaps }}
{{ include "helpers.configmaps.includeEnvConfigmap" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $general.envSecrets }}
{{ include "helpers.secrets.includeEnvSecret" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $v.envSecrets }}
{{ include "helpers.secrets.includeEnvSecret" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $general.envFrom }}
{{ include "helpers.tplvalues.render" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- with $v.envFrom }}
{{ include "helpers.tplvalues.render" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}

{{- define "helpers.workload.checksum" -}}
{{ . | toString | sha256sum }}
{{- end -}}
