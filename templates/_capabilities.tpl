{{- define "helpers.capabilities.helmVersion" -}}
{{- if and .Values.generic .Values.generic.helmVersion -}}
{{- .Values.generic.helmVersion -}}
{{- else if typeIs "string" .Capabilities.KubeVersion -}}
{{- "v2" -}}
{{- else -}}
{{- "v3" -}}
{{- end -}}
{{- end -}}

{{- define "helpers.capabilities.kubeVersion" -}}
{{- if and .Values.generic .Values.generic.kubeVersion -}}
{{- .Values.generic.kubeVersion -}}
{{- else if semverCompare "<3" (include "helpers.capabilities.helmVersion" $) -}}
{{- default .Capabilities.KubeVersion .Values.kubeVersion -}}
{{- else if .Capabilities.KubeVersion.Version -}}
{{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
{{- else -}}
{{- default .Capabilities.KubeVersion .Values.kubeVersion -}}
{{- end -}}
{{- end -}}

{{- define "helpers.capabilities.cronJob.apiVersion" -}}
{{- if and .Values.generic (hasKey .Values.generic "apiVersions") (kindIs "map" .Values.generic.apiVersions) .Values.generic.apiVersions.cronJob -}}
{{- .Values.generic.apiVersions.cronJob -}}
{{- else if semverCompare "<1.21-0" (include "helpers.capabilities.kubeVersion" $) -}}
{{- print "batch/v1beta1" -}}
{{- else -}}
{{- print "batch/v1" -}}
{{- end -}}
{{- end -}}

{{- define "helpers.capabilities.deployment.apiVersion" -}}
{{- if and .Values.generic (hasKey .Values.generic "apiVersions") (kindIs "map" .Values.generic.apiVersions) .Values.generic.apiVersions.deployment -}}
{{- .Values.generic.apiVersions.deployment -}}
{{- else if semverCompare "<1.14-0" (include "helpers.capabilities.kubeVersion" $) -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{- define "helpers.capabilities.statefulSet.apiVersion" -}}
{{- if and .Values.generic (hasKey .Values.generic "apiVersions") (kindIs "map" .Values.generic.apiVersions) .Values.generic.apiVersions.statefulSet -}}
{{- .Values.generic.apiVersions.statefulSet -}}
{{- else if semverCompare "<1.14-0" (include "helpers.capabilities.kubeVersion" $) -}}
{{- print "apps/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{- define "helpers.capabilities.ingress.apiVersion" -}}
{{- if and .Values.generic (hasKey .Values.generic "apiVersions") (kindIs "map" .Values.generic.apiVersions) .Values.generic.apiVersions.ingress -}}
{{- .Values.generic.apiVersions.ingress -}}
{{- else if semverCompare "<1.14-0" (include "helpers.capabilities.kubeVersion" $) -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "<1.19-0" (include "helpers.capabilities.kubeVersion" $) -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{- define "helpers.capabilities.pdb.apiVersion" -}}
{{- if and .Values.generic (hasKey .Values.generic "apiVersions") (kindIs "map" .Values.generic.apiVersions) .Values.generic.apiVersions.pdb -}}
{{- .Values.generic.apiVersions.pdb -}}
{{- else if semverCompare "<1.21-0" (include "helpers.capabilities.kubeVersion" $) -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "policy/v1" -}}
{{- end -}}
{{- end -}}

{{- define "helpers.capabilities.traefik.apiVersion" -}}
{{- if and .Values.generic (hasKey .Values.generic "apiVersions") (kindIs "map" .Values.generic.apiVersions) .Values.generic.apiVersions.traefik -}}
{{- .Values.generic.apiVersions.traefik -}}
{{- else if .Capabilities.APIVersions.Has "traefik.io/v1alpha1" -}}
{{- print "traefik.io/v1alpha1" -}}
{{- else if .Capabilities.APIVersions.Has "traefik.containo.us/v1alpha1" -}}
{{- print "traefik.containo.us/v1alpha1" -}}
{{- end -}}
{{- end -}}

{{- define "helpers.capabilities.istiogateway.apiVersion" -}}
{{- if and .Values.generic (hasKey .Values.generic "apiVersions") (kindIs "map" .Values.generic.apiVersions) .Values.generic.apiVersions.istioGateway -}}
{{- .Values.generic.apiVersions.istioGateway -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1" -}}
{{- print "networking.istio.io/v1" -}}
{{- else -}}
{{- print "networking.istio.io/v1" -}}
{{- end -}}
{{- end -}}

{{- define "helpers.capabilities.istiovirtualservice.apiVersion" -}}
{{- if and .Values.generic (hasKey .Values.generic "apiVersions") (kindIs "map" .Values.generic.apiVersions) .Values.generic.apiVersions.istioVirtualService -}}
{{- .Values.generic.apiVersions.istioVirtualService -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1" -}}
{{- print "networking.istio.io/v1" -}}
{{- else -}}
{{- print "networking.istio.io/v1" -}}
{{- end -}}
{{- end -}}

{{- define "helpers.capabilities.istiodestinationrule.apiVersion" -}}
{{- if and .Values.generic (hasKey .Values.generic "apiVersions") (kindIs "map" .Values.generic.apiVersions) .Values.generic.apiVersions.istioDestinationRule -}}
{{- .Values.generic.apiVersions.istioDestinationRule -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1" -}}
{{- print "networking.istio.io/v1" -}}
{{- else -}}
{{- print "networking.istio.io/v1" -}}
{{- end -}}
{{- end -}}
