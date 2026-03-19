{{- define "helpers.tplvalues.render" -}}
{{- if ne .value nil -}}
{{- if typeIs "string" .value -}}
{{- tpl .value .context -}}
{{- else -}}
{{- tpl (.value | toYaml) .context -}}
{{- end -}}
{{- end -}}
{{- end -}}
