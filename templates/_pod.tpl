{{- define "helpers.pod" -}}
{{- $ := .context -}}
{{- $general := .general | default dict -}}
{{- $extraLabels := .extraLabels | default dict -}}
{{- $usePredefinedAffinity := $.Values.generic.usePredefinedAffinity -}}
{{- if ne $general.usePredefinedAffinity nil }}{{- $usePredefinedAffinity = $general.usePredefinedAffinity -}}{{- end -}}
{{- $name := .name -}}
{{- $diagnosticEnabled := false -}}
{{- if $.Values.diagnosticMode -}}
{{- $diagnosticEnabled = or $.Values.diagnosticMode.enabled $.Values.diagnosticMode.enbled -}}
{{- end -}}
{{- with .value -}}
{{- $serviceAccountName := "" -}}
{{- if .serviceAccountName -}}
{{- $serviceAccountName = include "helpers.tplvalues.render" (dict "value" .serviceAccountName "context" $) -}}
{{- else if $.Values.generic.serviceAccountName -}}
{{- $serviceAccountName = include "helpers.tplvalues.render" (dict "value" $.Values.generic.serviceAccountName "context" $) -}}
{{- end -}}
{{- if $serviceAccountName }}
{{- if and (kindIs "map" $.Values.serviceAccount) (hasKey $.Values.serviceAccount $serviceAccountName) }}
serviceAccountName: {{ include "helpers.app.fullname" (dict "name" $serviceAccountName "context" $) }}
{{- else }}
serviceAccountName: {{ $serviceAccountName }}
{{- end }}
{{- end }}
{{- if .hostAliases }}
hostAliases: {{- include "helpers.tplvalues.render" (dict "value" .hostAliases "context" $) | nindent 2 }}
{{- else if $.Values.generic.hostAliases }}
hostAliases: {{- include "helpers.tplvalues.render" (dict "value" $.Values.generic.hostAliases "context" $) | nindent 2 }}
{{- end }}
{{- if .affinity }}
affinity: {{- include "helpers.tplvalues.render" (dict "value" .affinity "context" $) | nindent 2 }}
{{- else if $general.affinity }}
affinity: {{- include "helpers.tplvalues.render" (dict "value" $general.affinity "context" $) | nindent 2 }}
{{- else if $usePredefinedAffinity }}
affinity:
  nodeAffinity: {{- include "helpers.affinities.nodes" (dict "type" $.Values.nodeAffinityPreset.type "key" $.Values.nodeAffinityPreset.key "values" $.Values.nodeAffinityPreset.values "context" $) | nindent 4 }}
  podAffinity: {{- include "helpers.affinities.pods" (dict "type" $.Values.podAffinityPreset "extraLabels" $extraLabels "context" $) | nindent 4 }}
  podAntiAffinity: {{- include "helpers.affinities.pods" (dict "type" $.Values.podAntiAffinityPreset "extraLabels" $extraLabels "context" $) | nindent 4 }}
{{- end }}
{{- $topologySpreadConstraints := $.Values.generic.topologySpreadConstraints -}}
{{- if ne $general.topologySpreadConstraints nil }}{{- $topologySpreadConstraints = $general.topologySpreadConstraints -}}{{- end -}}
{{- if ne .topologySpreadConstraints nil }}{{- $topologySpreadConstraints = .topologySpreadConstraints -}}{{- end -}}
{{- with $topologySpreadConstraints }}
topologySpreadConstraints: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 2 }}
{{- end }}
{{- if .priorityClassName }}
priorityClassName: {{ .priorityClassName }}
{{- else if $.Values.generic.priorityClassName }}
priorityClassName: {{ $.Values.generic.priorityClassName }}
{{- end }}
{{- if .dnsPolicy }}
dnsPolicy: {{ .dnsPolicy }}
{{- else if $.Values.generic.dnsPolicy }}
dnsPolicy: {{ $.Values.generic.dnsPolicy }}
{{- end }}
{{- with .nodeSelector }}
nodeSelector: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 2 }}
{{- end }}
{{- $combinedTolerations := list -}}
{{- if .tolerations }}
{{- $combinedTolerations = .tolerations -}}
{{- else if $.Values.generic.tolerations }}
{{- $combinedTolerations = $.Values.generic.tolerations -}}
{{- end }}
{{- if $combinedTolerations }}
tolerations:
{{ toYaml $combinedTolerations | nindent 2 }}
{{- end }}
{{- with .securityContext }}
securityContext: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 2 }}
{{- end }}
{{- if or $.Values.imagePullSecrets $.Values.generic.extraImagePullSecrets .imagePullSecrets .extraImagePullSecrets }}
imagePullSecrets:
{{- range $sName := keys $.Values.imagePullSecrets | sortAlpha }}
- name: {{ $sName }}
{{- end }}
{{- with .imagePullSecrets }}{{ include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 0 }}{{- end }}
{{- with .extraImagePullSecrets }}{{ include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 0 }}{{- end }}
{{- with $.Values.generic.extraImagePullSecrets }}{{ include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 0 }}{{- end }}
{{- end }}
{{- if .terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ .terminationGracePeriodSeconds }}
{{- end }}
{{- $initContainers := fromYamlArray (include "helpers.workloads.containerEntries" (dict "value" .initContainers)) | default list -}}
{{- if $initContainers }}
initContainers:
{{- range $index, $container := $initContainers }}
  {{- $containerName := get $container "name" -}}
  {{- if $containerName }}
- name: {{ include "helpers.tplvalues.render" (dict "value" $containerName "context" $) }}
  {{- else }}
- name: {{ printf "%s-init-%d" $name $index }}
  {{- end }}
  {{- $image := $.Values.defaultImage -}}
  {{- with (get $container "image") }}{{- $image = include "helpers.tplvalues.render" (dict "value" . "context" $) -}}{{- end }}
  {{- $imageTag := $.Values.defaultImageTag -}}
  {{- with (get $container "imageTag") }}{{- $imageTag = include "helpers.tplvalues.render" (dict "value" . "context" $) -}}{{- end }}
  image: {{ $image }}:{{ $imageTag }}
  imagePullPolicy: {{ get $container "imagePullPolicy" | default $.Values.defaultImagePullPolicy }}
  {{- with (get $container "securityContext") }}
  securityContext: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  {{- if $diagnosticEnabled }}
  args: {{- include "helpers.tplvalues.render" (dict "value" $.Values.diagnosticMode.args "context" $) | nindent 2 }}
  {{- else if (get $container "args") }}
  args: {{- include "helpers.tplvalues.render" (dict "value" (get $container "args") "context" $) | nindent 2 }}
  {{- end }}
  {{- if $diagnosticEnabled }}
  command: {{- include "helpers.tplvalues.render" (dict "value" $.Values.diagnosticMode.command "context" $) | nindent 2 }}
  {{- else if (get $container "command") }}
    {{- if typeIs "string" (get $container "command") }}
  command: {{ printf "[\"%s\"]" (join "\", \"" (without (splitList " " (get $container "command")) "")) }}
    {{- else }}
  command: {{- include "helpers.tplvalues.render" (dict "value" (get $container "command") "context" $) | nindent 2 }}
    {{- end }}
  {{- end }}
{{ include "helpers.workloads.envs" (dict "value" $container "context" $) | nindent 2 }}
{{ include "helpers.workloads.envsFrom" (dict "value" $container "context" $) | nindent 2 }}
  {{- with (get $container "ports") }}
  ports: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 2 }}
  {{- end }}
  {{- with (get $container "lifecycle") }}
  lifecycle: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  {{- with (get $container "startupProbe") }}
  startupProbe: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  {{- with (get $container "livenessProbe") }}
  livenessProbe: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  {{- with (get $container "readinessProbe") }}
  readinessProbe: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  {{- with (get $container "resources") }}
  resources: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  volumeMounts: {{- include "helpers.volumes.renderVolumeMounts" (dict "value" $container "general" $general "context" $) | nindent 4 }}
{{- end }}
{{- end }}
{{- $containers := fromYamlArray (include "helpers.workloads.containerEntries" (dict "value" .containers)) | default list -}}
{{- if $containers }}
containers:
{{- range $index, $container := $containers }}
  {{- $containerName := get $container "name" -}}
  {{- if $containerName }}
- name: {{ include "helpers.tplvalues.render" (dict "value" $containerName "context" $) }}
  {{- else }}
- name: {{ printf "%s-%d" $name $index }}
  {{- end }}
  {{- $image := $.Values.defaultImage -}}
  {{- with (get $container "image") }}{{- $image = include "helpers.tplvalues.render" (dict "value" . "context" $) -}}{{- end }}
  {{- $imageTag := $.Values.defaultImageTag -}}
  {{- with (get $container "imageTag") }}{{- $imageTag = include "helpers.tplvalues.render" (dict "value" . "context" $) -}}{{- end }}
  image: {{ $image }}:{{ $imageTag }}
  imagePullPolicy: {{ get $container "imagePullPolicy" | default $.Values.defaultImagePullPolicy }}
  {{- with (get $container "securityContext") }}
  securityContext: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  {{- if $diagnosticEnabled }}
  args: {{- include "helpers.tplvalues.render" (dict "value" $.Values.diagnosticMode.args "context" $) | nindent 2 }}
  {{- else if (get $container "args") }}
  args: {{- include "helpers.tplvalues.render" (dict "value" (get $container "args") "context" $) | nindent 2 }}
  {{- end }}
  {{- if $diagnosticEnabled }}
  command: {{- include "helpers.tplvalues.render" (dict "value" $.Values.diagnosticMode.command "context" $) | nindent 2 }}
  {{- else if (get $container "command") }}
    {{- if typeIs "string" (get $container "command") }}
  command: {{ printf "[\"%s\"]" (join "\", \"" (without (splitList " " (get $container "command")) "")) }}
    {{- else }}
  command: {{- include "helpers.tplvalues.render" (dict "value" (get $container "command") "context" $) | nindent 2 }}
    {{- end }}
  {{- end }}
{{ include "helpers.workloads.envs" (dict "value" $container "general" $general "context" $) | nindent 2 }}
{{ include "helpers.workloads.envsFrom" (dict "value" $container "general" $general "context" $) | nindent 2 }}
  {{- with (get $container "ports") }}
  ports: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 2 }}
  {{- end }}
  {{- with (get $container "lifecycle") }}
  lifecycle: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  {{- with (get $container "startupProbe") }}
  startupProbe: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  {{- with (get $container "livenessProbe") }}
  livenessProbe: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  {{- with (get $container "readinessProbe") }}
  readinessProbe: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  {{- with (get $container "resources") }}
  resources: {{- include "helpers.tplvalues.render" (dict "value" . "context" $) | nindent 4 }}
  {{- end }}
  volumeMounts: {{- include "helpers.volumes.renderVolumeMounts" (dict "value" $container "general" $general "context" $) | nindent 4 }}
{{- end }}
{{- end }}
volumes: {{- include "helpers.volumes.renderVolume" (dict "value" . "general" $general "context" $) | nindent 2 }}
{{- end }}
{{- end -}}
