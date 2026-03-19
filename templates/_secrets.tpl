{{- define "helpers.secrets.includeEnv" -}}
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
{{- if kindIs "string" $envKey -}}
- name: {{ $envKey }}
  valueFrom:
    secretKeyRef:
      name: {{ include "helpers.app.fullname" (dict "name" $sName "context" $ctx) }}
      key: {{ $envKey }}
{{- else if kindIs "map" $envKey -}}
{{- range $keyName := keys $envKey | sortAlpha -}}
- name: {{ $keyName }}
  valueFrom:
    secretKeyRef:
      name: {{ include "helpers.app.fullname" (dict "name" $sName "context" $ctx) }}
      key: {{ get $envKey $keyName }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "helpers.secrets.includeEnvSecret" -}}
{{- $ctx := .context -}}
{{- range $sName := .value -}}
- secretRef:
    name: {{ include "helpers.app.fullname" (dict "name" $sName "context" $ctx) }}
{{- end -}}
{{- end -}}

{{- define "helpers.secrets.encode" -}}
{{- if hasPrefix "b64:" .value -}}
{{ trimPrefix "b64:" .value }}
{{- else -}}
{{ toString .value | b64enc }}
{{- end -}}
{{- end -}}

{{- define "helpers.secrets.render" -}}
{{- $ctx := .context -}}
{{- $v := dict -}}
{{- if kindIs "string" .value -}}
{{- $v = fromYaml .value | default dict -}}
{{- else -}}
{{- $v = .value | default dict -}}
{{- end -}}
{{- range $key := keys $v | sortAlpha -}}
{{- $value := get $v $key -}}
{{- if kindIs "string" $value -}}
{{- $rendered := $value -}}
{{- if $ctx -}}
{{- $rendered = include "helpers.tplvalues.render" (dict "value" $value "context" $ctx) -}}
{{- end -}}
{{ printf "%s: %s\n" $key (include "helpers.secrets.encode" (dict "value" $rendered)) }}
{{- else -}}
{{ printf "%s: %s\n" $key ($value | toJson | b64enc) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "helpers.secrets.renderSealed" -}}
{{- $v := dict -}}
{{- if kindIs "string" .value -}}
{{- $v = fromYaml .value | default dict -}}
{{- else -}}
{{- $v = .value | default dict -}}
{{- end -}}
{{- range $key := keys $v | sortAlpha -}}
{{ printf "%s: %s\n" $key (get $v $key) }}
{{- end -}}
{{- end -}}
