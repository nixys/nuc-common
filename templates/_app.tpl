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

{{/*
Default hook annotations for generated ConfigMaps and Secrets.

Backward compatibility:
- if generic.hookAnnotations is not defined, keep the historical defaults
- if generic.hookAnnotations is defined as null, disable default hook annotations
*/}}
{{- define "helpers.app.defaultHookAnnotations" -}}
{{- $defaultHookAnnotations := dict "helm.sh/hook" "pre-install,pre-upgrade" "helm.sh/hook-weight" "-999" "helm.sh/hook-delete-policy" "before-hook-creation" -}}
{{- if and .Values.generic (hasKey .Values.generic "hookAnnotations") -}}
  {{- with .Values.generic.hookAnnotations }}
{{ include "helpers.tplvalues.render" (dict "value" . "context" $) }}
  {{- end -}}
{{- else -}}
{{ toYaml $defaultHookAnnotations }}
{{- end -}}
{{- end -}}

{{/*
Backward-compatible alias retained for older charts.
*/}}
{{- define "helpers.app.hooksAnnotations" -}}
{{- $ctx := .context | default . -}}
{{- include "helpers.app.defaultHookAnnotations" $ctx -}}
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

{{/*
Merge resource metadata annotations without duplicate keys.

Order of precedence (later wins):
- default hook annotations when includeHooks=true
- fixedAnnotations
- generic annotations
- gitops annotations
- general.annotations
- value.annotations
- extraAnnotations
*/}}
{{- define "helpers.app.annotations" -}}
{{- $ctx := .context -}}
{{- $general := .general | default dict -}}
{{- $value := .value | default dict -}}
{{- $annotations := dict -}}
{{- if .includeHooks -}}
  {{- with (include "helpers.app.defaultHookAnnotations" $ctx | fromYaml) -}}
    {{- $annotations = mergeOverwrite $annotations . -}}
  {{- end -}}
{{- end -}}
{{- with .fixedAnnotations -}}
  {{- if kindIs "string" . -}}
    {{- $annotations = mergeOverwrite $annotations ((fromYaml .) | default dict) -}}
  {{- else -}}
    {{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}
  {{- end -}}
{{- end -}}
{{- with (include "helpers.app.genericAnnotations" $ctx | fromYaml) -}}
  {{- $annotations = mergeOverwrite $annotations . -}}
{{- end -}}
{{- with (include "helpers.app.gitopsAnnotations" (dict "context" $ctx "general" $general "value" $value) | fromYaml) -}}
  {{- $annotations = mergeOverwrite $annotations . -}}
{{- end -}}
{{- with (get $general "annotations") -}}
  {{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}
{{- end -}}
{{- with (get $value "annotations") -}}
  {{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}
{{- end -}}
{{- with .extraAnnotations -}}
  {{- if kindIs "string" . -}}
    {{- $annotations = mergeOverwrite $annotations ((fromYaml .) | default dict) -}}
  {{- else -}}
    {{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}
  {{- end -}}
{{- end -}}
{{- if $annotations }}{{ toYaml $annotations }}{{- end -}}
{{- end -}}

{{/*
Render pod/container securityContext with optional generic defaults.

If mergeWithGeneric=true is set on the specific securityContext, generic keys are
merged first and the specific keys override them. Otherwise the specific value
replaces the generic default.
*/}}
{{- define "helpers.securityContext" -}}
{{- $ctx := .context -}}
{{- $specific := .securityContext -}}
{{- $generic := .genericSecurityContext -}}
{{- $final := dict -}}
{{- if and $specific (kindIs "map" $specific) (get $specific "mergeWithGeneric") $generic -}}
  {{- $final = mergeOverwrite $final ($generic | default dict) (omit $specific "mergeWithGeneric") -}}
{{- else if $specific -}}
  {{- if and (kindIs "map" $specific) (hasKey $specific "mergeWithGeneric") -}}
    {{- $final = omit $specific "mergeWithGeneric" -}}
  {{- else -}}
    {{- $final = $specific -}}
  {{- end -}}
{{- else if $generic -}}
  {{- $final = $generic -}}
{{- end -}}
{{- if $final }}
securityContext: {{- include "helpers.tplvalues.render" (dict "value" $final "context" $ctx) | nindent 2 }}
{{- end -}}
{{- end -}}

{{/*
Render imagePullSecrets for generated ServiceAccounts.

The general and local imagePullSecrets blocks support:
- includePlatformDefault: bool
- additional: [{name: regcred}] or ["regcred"]

The local value can also be provided directly as a list for convenience.
*/}}
{{- define "helpers.serviceAccounts.imagePullSecrets" -}}
{{- $ctx := .context -}}
{{- $general := .general | default dict -}}
{{- $value := .value | default dict -}}
{{- $generalConfig := get $general "imagePullSecrets" | default dict -}}
{{- $valueConfig := get $value "imagePullSecrets" -}}
{{- $includeDefault := false -}}
{{- if and (kindIs "map" $generalConfig) (hasKey $generalConfig "includePlatformDefault") -}}
  {{- $includeDefault = $generalConfig.includePlatformDefault -}}
{{- end -}}
{{- if and (kindIs "map" $valueConfig) (hasKey $valueConfig "includePlatformDefault") -}}
  {{- $includeDefault = $valueConfig.includePlatformDefault -}}
{{- end -}}
{{- $items := list -}}
{{- if and (kindIs "map" $generalConfig) (kindIs "slice" ($generalConfig.additional | default list)) -}}
  {{- $items = concat $items ($generalConfig.additional | default list) -}}
{{- end -}}
{{- if kindIs "slice" $valueConfig -}}
  {{- $items = concat $items $valueConfig -}}
{{- else if and (kindIs "map" $valueConfig) (kindIs "slice" ($valueConfig.additional | default list)) -}}
  {{- $items = concat $items ($valueConfig.additional | default list) -}}
{{- end -}}
{{- $names := list -}}
{{- if and $includeDefault $ctx.Values.serviceAccountDefaultImagePullSecretName -}}
  {{- $names = append $names $ctx.Values.serviceAccountDefaultImagePullSecretName -}}
{{- end -}}
{{- range $item := $items -}}
  {{- if kindIs "string" $item -}}
    {{- $names = append $names $item -}}
  {{- else if and (kindIs "map" $item) (hasKey $item "name") -}}
    {{- $names = append $names ($item.name | toString) -}}
  {{- end -}}
{{- end -}}
{{- $seen := dict -}}
{{- $rendered := list -}}
{{- range $name := $names -}}
  {{- $resolvedName := include "helpers.tplvalues.render" (dict "value" $name "context" $ctx) -}}
  {{- if and $resolvedName (not (hasKey $seen $resolvedName)) -}}
    {{- $_ := set $seen $resolvedName true -}}
    {{- $rendered = append $rendered (dict "name" $resolvedName) -}}
  {{- end -}}
{{- end -}}
{{- if $rendered }}
imagePullSecrets:
{{- range $entry := $rendered }}
  - name: {{ $entry.name | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Merge pod-level annotations without duplicate keys.

Order of precedence (later wins):
- automatic checksum annotations
- generic pod annotations
- general.podAnnotations
- value.podAnnotations
- extraAnnotations
*/}}
{{- define "helpers.workloads.podAnnotations" -}}
{{- $ctx := .context -}}
{{- $general := .general | default dict -}}
{{- $value := .value | default dict -}}
{{- $annotations := dict -}}
{{- with (include "helpers.workloads.autoChecksumAnnotations" (dict "context" $ctx "general" $general "value" $value) | fromYaml) -}}
  {{- $annotations = mergeOverwrite $annotations . -}}
{{- end -}}
{{- if and $ctx.Values.generic (hasKey $ctx.Values.generic "podAnnotations") -}}
  {{- with $ctx.Values.generic.podAnnotations -}}
    {{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}
  {{- end -}}
{{- end -}}
{{- with (get $general "podAnnotations") -}}
  {{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}
{{- end -}}
{{- with (get $value "podAnnotations") -}}
  {{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}
{{- end -}}
{{- with .extraAnnotations -}}
  {{- if kindIs "string" . -}}
    {{- $annotations = mergeOverwrite $annotations ((fromYaml .) | default dict) -}}
  {{- else -}}
    {{- $annotations = mergeOverwrite $annotations ((fromYaml (include "helpers.tplvalues.render" (dict "value" . "context" $ctx))) | default dict) -}}
  {{- end -}}
{{- end -}}
{{- if $annotations }}{{ toYaml $annotations }}{{- end -}}
{{- end -}}

{{- define "helpers.app.defaultURL" -}}
{{- if .Values.defaultURL -}}
{{- .Values.defaultURL -}}
{{- else if and .Values.generic .Values.generic.defaultURL -}}
{{- .Values.generic.defaultURL -}}
{{- end -}}
{{- end -}}
