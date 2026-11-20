{{- define "helpers.workloads.envs" -}}
{{- $ctx := .context -}}
{{- $general := .general | default dict -}}
{{- $v := .value | default dict -}}
{{- $envs := list $general.env $v.env -}}
{{- if and (kindIs "map" $general.env) (kindIs "map" $v.env) -}}
{{- $merged := dict -}}
{{- range $key, $value := $general.env }}{{ $_ := set $merged $key $value }}{{ end -}}
{{- range $key, $value := $v.env }}{{ $_ := set $merged $key $value }}{{ end -}}
{{- $envs = list $merged -}}
{{- end -}}
{{- $hasEnv := false -}}
{{- range $envs -}}
{{- if kindIs "map" . -}}
{{- range $_, $value := . -}}
{{- if ne $value nil -}}{{- $hasEnv = true -}}{{- end -}}
{{- end -}}
{{- else if . -}}
{{- $hasEnv = true -}}
{{- end -}}
{{- end -}}
{{- if or $general.envsFromConfigmap $v.envsFromConfigmap $general.envsFromSecret $v.envsFromSecret $hasEnv -}}
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
{{- range $envs }}
{{- if kindIs "map" . }}
{{- $seen := dict }}
{{- range $key, $value := . }}
{{- if ne $value nil }}
{{- $name := $key }}
{{- if contains "{{" $key }}
{{- $name = include "helpers.tplvalues.render" (dict "value" $key "context" $ctx) }}
{{- end }}
{{- if not $name }}
{{- fail (printf "env: variable name %q renders to an empty string" $key) }}
{{- end }}
{{- if hasKey $seen $name }}
{{- fail (printf "env: variable names %q and %q both render to %q" (get $seen $name) $key $name) }}
{{- end }}
{{- $_ := set $seen $name $key }}
  - name: {{ $name | quote }}
{{- if kindIs "map" $value }}
{{- if not $value.valueFrom }}
{{- fail (printf "env: variable %q must be a string, null, or an object with valueFrom" $key) }}
{{- end }}
    valueFrom: {{- include "helpers.tplvalues.render" (dict "value" $value.valueFrom "context" $ctx) | nindent 6 }}
{{- else }}
    value: {{ include "helpers.tplvalues.render" (dict "value" $value "context" $ctx) | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- else if . }}
{{ include "helpers.tplvalues.render" (dict "value" . "context" $ctx) | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}
{{- end -}}

{{- define "helpers.workloads.envsFrom" -}}
{{- $ctx := .context -}}
{{- $general := .general | default dict -}}
{{- $v := .value | default dict -}}
{{- $envFrom := "" -}}
{{- with $general.envConfigmaps }}
{{- $envFrom = printf "%s\n%s" $envFrom (include "helpers.configmaps.includeEnvConfigmap" (dict "value" . "context" $ctx)) -}}
{{- end }}
{{- with $v.envConfigmaps }}
{{- $envFrom = printf "%s\n%s" $envFrom (include "helpers.configmaps.includeEnvConfigmap" (dict "value" . "context" $ctx)) -}}
{{- end }}
{{- with $general.envSecrets }}
{{- $envFrom = printf "%s\n%s" $envFrom (include "helpers.secrets.includeEnvSecret" (dict "value" . "context" $ctx)) -}}
{{- end }}
{{- with $v.envSecrets }}
{{- $envFrom = printf "%s\n%s" $envFrom (include "helpers.secrets.includeEnvSecret" (dict "value" . "context" $ctx)) -}}
{{- end }}
{{- with $general.envFrom }}
{{- $envFrom = printf "%s\n%s" $envFrom (include "helpers.tplvalues.render" (dict "value" . "context" $ctx)) -}}
{{- end }}
{{- with $v.envFrom }}
{{- $envFrom = printf "%s\n%s" $envFrom (include "helpers.tplvalues.render" (dict "value" . "context" $ctx)) -}}
{{- end }}
{{- $envFrom = trim $envFrom -}}
{{- if $envFrom }}
envFrom:
{{ $envFrom | nindent 2 }}
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
