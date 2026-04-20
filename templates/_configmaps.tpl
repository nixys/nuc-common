{{- define "helpers.configmaps.decode" -}}
{{- if hasPrefix "b64:" .value -}}
{{ trimPrefix "b64:" .value | b64dec | quote }}
{{- else -}}
{{ quote .value }}
{{- end -}}
{{- end -}}

{{- define "helpers.configmaps.renderConfigMap" -}}
{{- $ctx := .context -}}
{{- $v := dict -}}
{{- if typeIs "string" .value -}}
{{- $v = fromYaml .value | default dict -}}
{{- else if kindIs "map" .value -}}
{{- $v = .value -}}
{{- end -}}
{{- range $key := keys $v | sortAlpha -}}
{{- $value := get $v $key -}}
{{- if eq (typeOf $value) "float64" -}}
{{ printf "%s: %s\n" $key (include "helpers.configmaps.decode" (dict "value" $value)) }}
{{- else if empty $value -}}
{{ printf "%s: %s\n" $key ("" | quote) }}
{{- else if kindIs "string" $value -}}
{{- $rendered := $value -}}
{{- if $ctx -}}
{{- $rendered = include "helpers.tplvalues.render" (dict "value" $value "context" $ctx) -}}
{{- end -}}
{{ printf "%s: %s\n" $key (include "helpers.configmaps.decode" (dict "value" $rendered)) }}
{{- else -}}
{{ printf "%s: %s\n" $key ($value | toJson | quote) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "helpers.configmaps.includeEnv" -}}
{{- $ctx := .context -}}
{{- $s := dict -}}
{{- if typeIs "string" .value -}}
{{- $s = fromYaml .value | default dict -}}
{{- else if kindIs "map" .value -}}
{{- $s = .value -}}
{{- end -}}
{{- range $sName := keys $s | sortAlpha -}}
{{- $envKeys := get $s $sName -}}
{{- range $envKey := $envKeys -}}
{{- if kindIs "string" $envKey }}
- name: {{ $envKey }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "helpers.app.fullname" (dict "name" $sName "context" $ctx) }}
      key: {{ $envKey }}
{{- else if kindIs "map" $envKey }}
{{- range $keyName := keys $envKey | sortAlpha }}
- name: {{ $keyName }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "helpers.app.fullname" (dict "name" $sName "context" $ctx) }}
      key: {{ get $envKey $keyName }}
{{- end }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "helpers.configmaps.includeEnvConfigmap" -}}
{{- $ctx := .context -}}
{{- range $sName := .value }}
- configMapRef:
    name: {{ include "helpers.app.fullname" (dict "name" $sName "context" $ctx) }}
{{- end }}
{{- end -}}
