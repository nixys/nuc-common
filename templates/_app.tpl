{{- define "helpers.app.name" -}}
{{- $name := default .Release.Name .Values.nameOverride -}}
{{- if and .Values.generic (hasKey .Values.generic "fullnameOverride") .Values.generic.fullnameOverride -}}
{{- $name = include "helpers.tplvalues.render" (dict "value" .Values.generic.fullnameOverride "context" .) -}}
{{- end -}}
{{- if and .Values.generic (hasKey .Values.generic "nameSuffix") .Values.generic.nameSuffix -}}
{{- $name = printf "%s-%s" $name (include "helpers.tplvalues.render" (dict "value" .Values.generic.nameSuffix "context" .)) -}}
{{- end -}}
{{- $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "helpers.app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "helpers.app.fullname" -}}
{{- if .name -}}
{{- if eq .context.Values.releasePrefix "-" -}}
{{- .name | trunc 63 | trimSuffix "-" -}}
{{- else if .context.Values.releasePrefix -}}
{{- printf "%s-%s" .context.Values.releasePrefix .name | trunc 63 | trimAll "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "helpers.app.name" .context) .name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- else -}}
{{- include "helpers.app.name" .context -}}
{{- end -}}
{{- end -}}

{{- define "helpers.app.genericSelectorLabels" -}}
{{- if and $.Values.generic (hasKey $.Values.generic "extraSelectorLabels") -}}
{{- with $.Values.generic.extraSelectorLabels -}}
{{ include "helpers.tplvalues.render" (dict "value" . "context" $) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "helpers.app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helpers.app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{ include "helpers.app.genericSelectorLabels" $ }}
{{- end -}}

{{- define "helpers.app.labels" -}}
{{ include "helpers.app.selectorLabels" . }}
helm.sh/chart: {{ include "helpers.app.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- if and .Values.generic (hasKey .Values.generic "labels") -}}
{{- with .Values.generic.labels }}
{{ include "helpers.tplvalues.render" (dict "value" . "context" $) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "helpers.app.genericAnnotations" -}}
{{- if and .Values.generic (hasKey .Values.generic "annotations") -}}
{{- with .Values.generic.annotations }}
{{ include "helpers.tplvalues.render" (dict "value" . "context" $) }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "helpers.app.gitopsLabels" -}}
{{- $ctx := .context -}}
{{- $general := .general | default dict -}}
{{- $value := .value | default dict -}}
{{- $labels := dict -}}
{{- $globalGitops := $ctx.Values.gitops | default dict -}}
{{- $generalGitops := get $general "gitops" | default dict -}}
{{- $valueGitops := get $value "gitops" | default dict -}}
{{- with (get $globalGitops "commonLabels") }}{{- $labels = mergeOverwrite $labels ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- with (get $generalGitops "commonLabels") }}{{- $labels = mergeOverwrite $labels ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- with (get $valueGitops "commonLabels") }}{{- $labels = mergeOverwrite $labels ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- $fluxEnabled := false -}}
{{- $globalFlux := get $globalGitops "flux" | default dict -}}
{{- $generalFlux := get $generalGitops "flux" | default dict -}}
{{- $valueFlux := get $valueGitops "flux" | default dict -}}
{{- if hasKey $globalFlux "enabled" }}{{- $fluxEnabled = $globalFlux.enabled -}}{{- end -}}
{{- if hasKey $generalFlux "enabled" }}{{- $fluxEnabled = $generalFlux.enabled -}}{{- end -}}
{{- if hasKey $valueFlux "enabled" }}{{- $fluxEnabled = $valueFlux.enabled -}}{{- end -}}
{{- if $fluxEnabled -}}
{{- with (get $globalFlux "labels") }}{{- $labels = mergeOverwrite $labels ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- with (get $generalFlux "labels") }}{{- $labels = mergeOverwrite $labels ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- with (get $valueFlux "labels") }}{{- $labels = mergeOverwrite $labels ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- end -}}
{{- if $labels }}{{ toYaml $labels }}{{- end -}}
{{- end -}}

{{- define "helpers.app.gitopsAnnotations" -}}
{{- $ctx := .context -}}
{{- $general := .general | default dict -}}
{{- $value := .value | default dict -}}
{{- $annotations := dict -}}
{{- $globalGitops := $ctx.Values.gitops | default dict -}}
{{- $generalGitops := get $general "gitops" | default dict -}}
{{- $valueGitops := get $value "gitops" | default dict -}}
{{- with (get $globalGitops "commonAnnotations") }}{{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- with (get $generalGitops "commonAnnotations") }}{{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- with (get $valueGitops "commonAnnotations") }}{{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- $argoEnabled := false -}}
{{- $syncWave := "" -}}
{{- $syncOptions := list -}}
{{- $compareOptions := list -}}
{{- $globalArgo := get $globalGitops "argo" | default dict -}}
{{- $generalArgo := get $generalGitops "argo" | default dict -}}
{{- $valueArgo := get $valueGitops "argo" | default dict -}}
{{- if hasKey $globalArgo "enabled" }}{{- $argoEnabled = $globalArgo.enabled -}}{{- end -}}
{{- if hasKey $generalArgo "enabled" }}{{- $argoEnabled = $generalArgo.enabled -}}{{- end -}}
{{- if hasKey $valueArgo "enabled" }}{{- $argoEnabled = $valueArgo.enabled -}}{{- end -}}
{{- if hasKey $globalArgo "syncWave" }}{{- $syncWave = get $globalArgo "syncWave" -}}{{- end -}}
{{- if hasKey $generalArgo "syncWave" }}{{- $syncWave = get $generalArgo "syncWave" -}}{{- end -}}
{{- if hasKey $valueArgo "syncWave" }}{{- $syncWave = get $valueArgo "syncWave" -}}{{- end -}}
{{- if hasKey $globalArgo "syncOptions" }}{{- $syncOptions = get $globalArgo "syncOptions" | default list -}}{{- end -}}
{{- if hasKey $generalArgo "syncOptions" }}{{- $syncOptions = get $generalArgo "syncOptions" | default list -}}{{- end -}}
{{- if hasKey $valueArgo "syncOptions" }}{{- $syncOptions = get $valueArgo "syncOptions" | default list -}}{{- end -}}
{{- if hasKey $globalArgo "compareOptions" }}{{- $compareOptions = get $globalArgo "compareOptions" | default list -}}{{- end -}}
{{- if hasKey $generalArgo "compareOptions" }}{{- $compareOptions = get $generalArgo "compareOptions" | default list -}}{{- end -}}
{{- if hasKey $valueArgo "compareOptions" }}{{- $compareOptions = get $valueArgo "compareOptions" | default list -}}{{- end -}}
{{- if $argoEnabled -}}
{{- with $syncWave }}{{- $_ := set $annotations "argocd.argoproj.io/sync-wave" (include "helpers.tplvalues.render" (dict "value" . "context" $ctx)) -}}{{- end -}}
{{- if $syncOptions }}
{{- $renderedSyncOptions := fromYamlArray (include "helpers.tplvalues.render" (dict "value" $syncOptions "context" $ctx)) | default list -}}
{{- $_ := set $annotations "argocd.argoproj.io/sync-options" (join "," $renderedSyncOptions) -}}
{{- end -}}
{{- if $compareOptions }}
{{- $renderedCompareOptions := fromYamlArray (include "helpers.tplvalues.render" (dict "value" $compareOptions "context" $ctx)) | default list -}}
{{- $_ := set $annotations "argocd.argoproj.io/compare-options" (join "," $renderedCompareOptions) -}}
{{- end -}}
{{- end -}}
{{- $fluxEnabled := false -}}
{{- $globalFlux := get $globalGitops "flux" | default dict -}}
{{- $generalFlux := get $generalGitops "flux" | default dict -}}
{{- $valueFlux := get $valueGitops "flux" | default dict -}}
{{- if hasKey $globalFlux "enabled" }}{{- $fluxEnabled = $globalFlux.enabled -}}{{- end -}}
{{- if hasKey $generalFlux "enabled" }}{{- $fluxEnabled = $generalFlux.enabled -}}{{- end -}}
{{- if hasKey $valueFlux "enabled" }}{{- $fluxEnabled = $valueFlux.enabled -}}{{- end -}}
{{- if $fluxEnabled -}}
{{- with (get $globalFlux "annotations") }}{{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- with (get $generalFlux "annotations") }}{{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- with (get $valueFlux "annotations") }}{{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}{{- end -}}
{{- end -}}
{{- if $annotations }}{{ toYaml $annotations }}{{- end -}}
{{- end -}}

{{- define "helpers.app.hooksAnnotations" -}}
helm.sh/hook: "pre-install,pre-upgrade"
helm.sh/hook-weight: "-999"
helm.sh/hook-delete-policy: before-hook-creation
{{- end -}}

{{- define "helpers.app.defaultURL" -}}
{{- if .Values.defaultURL -}}
{{- .Values.defaultURL -}}
{{- else if and .Values.generic .Values.generic.defaultURL -}}
{{- .Values.generic.defaultURL -}}
{{- end -}}
{{- end -}}
