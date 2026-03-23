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

{{- define "helpers.workloads.gitOpsSafeMode" -}}
{{ include "helpers.workloads.deterministicNames" . }}
{{- end -}}

{{- define "helpers.workloads.deterministicNames" -}}
{{- $ctx := .context -}}
{{- $deterministicNames := true -}}
{{- if and $ctx.Values.generic (hasKey $ctx.Values.generic "deterministicNames") -}}
{{- $deterministicNames = $ctx.Values.generic.deterministicNames -}}
{{- else if and $ctx.Values.gitOps (hasKey $ctx.Values.gitOps "safeMode") -}}
{{- $deterministicNames = $ctx.Values.gitOps.safeMode -}}
{{- end -}}
{{- if $deterministicNames -}}true{{- else -}}false{{- end -}}
{{- end -}}

{{- define "helpers.workloads.modeEnabled" -}}
{{- $mode := default "auto" .context.Values.workloadMode | lower -}}
{{- $kind := .kind | lower -}}
{{- if eq $mode "auto" -}}
true
{{- else if eq $mode "none" -}}
false
{{- else if and (eq $mode "deployment") (eq $kind "deployment") -}}
true
{{- else if and (eq $mode "statefulset") (eq $kind "statefulset") -}}
true
{{- else if and (or (eq $mode "batch") (eq $mode "jobs") (eq $mode "jobs-only") (eq $mode "jobsonly")) (or (eq $kind "job") (eq $kind "cronjob") (eq $kind "hook")) -}}
true
{{- else if and (eq $mode "job") (eq $kind "job") -}}
true
{{- else if and (eq $mode "cronjob") (eq $kind "cronjob") -}}
true
{{- else if and (eq $mode "hook") (eq $kind "hook") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "helpers.workloads.containerEntries" -}}
{{- $entries := list -}}
{{- if kindIs "map" .value -}}
  {{- range $entryName := keys .value | sortAlpha -}}
    {{- $entry := (fromYaml (toYaml (get $.value $entryName | default dict))) | default dict -}}
    {{- if not (hasKey $entry "name") }}{{- $_ := set $entry "name" $entryName -}}{{- end -}}
    {{- $entries = append $entries $entry -}}
  {{- end -}}
{{- else if kindIs "slice" .value -}}
  {{- range .value -}}
    {{- $entries = append $entries ((fromYaml (toYaml (. | default dict))) | default dict) -}}
  {{- end -}}
{{- end -}}
{{ toYaml $entries }}
{{- end -}}

{{- define "helpers.workload.checksum" -}}
{{ . | toString | sha256sum }}
{{- end -}}
