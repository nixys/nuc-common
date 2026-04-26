# nuc-common

`nuc-common` is the shared Helm library chart used by `nxs-universal-chart` and related charts.

## Annotation Helpers

The library exposes merged annotation helpers to keep rendered manifests deterministic and avoid duplicate YAML keys:

- `helpers.app.defaultHookAnnotations`
- `helpers.app.hooksAnnotations`
- `helpers.app.annotations`
- `helpers.securityContext`
- `helpers.serviceAccounts.imagePullSecrets`
- `helpers.workloads.podAnnotations`

### Hook annotation behavior

- If `generic.hookAnnotations` is not defined, the historical default hook annotations are emitted:
  - `helm.sh/hook: "pre-install,pre-upgrade"`
  - `helm.sh/hook-weight: "-999"`
  - `helm.sh/hook-delete-policy: before-hook-creation`
- If `generic.hookAnnotations` is defined as `null`, default hook annotations are disabled.
- If `generic.hookAnnotations` is defined as a map, that map is rendered through `tpl` and used as the default hook annotation set.

### Merge precedence

`helpers.app.annotations` merges sources in this order, with later values overriding earlier ones:

1. Default hook annotations when enabled
2. Fixed annotations passed by the caller
3. `generic.annotations`
4. GitOps annotations
5. `general.annotations`
6. Resource-level `annotations`
7. Extra annotations passed by the caller

`helpers.workloads.podAnnotations` applies the same no-duplicate merge model for checksum annotations and pod-level annotation maps.

## SecurityContext Helper

`helpers.securityContext` renders pod/container security contexts with support for generic defaults:

- `generic.podSecurityContext` is used for workload-level pod specs.
- `generic.containerSecurityContext` is used for containers and initContainers.
- If a specific `securityContext` sets `mergeWithGeneric: true`, generic keys are merged first and the specific keys override them.
- Otherwise, a specific `securityContext` replaces the generic default.

## Workload envFrom helpers

`helpers.workloads.envsFrom` renders `envFrom` entries from `envConfigmaps`, `envSecrets`, and raw `envFrom` values defined on a container or workload-family general defaults object.

- Multiple `envConfigmaps` and `envSecrets` entries are preserved in order.
- Empty strings and `null` items are skipped.
- If no valid entries remain, the `envFrom` block is omitted.

## ServiceAccount imagePullSecrets

`helpers.serviceAccounts.imagePullSecrets` renders generated `ServiceAccount.imagePullSecrets` from:

- `serviceAccountDefaultImagePullSecretName`
- `serviceAccountGeneral.imagePullSecrets`
- `serviceAccount.<name>.imagePullSecrets`

Supported shape:

- `includePlatformDefault: true|false`
- `additional: [{name: regcred}]` or `["regcred"]`

The helper also deduplicates repeated secret names after `tpl` rendering.

## Projected Volumes

Typed volumes now support `type: projected` with a raw `sources` array rendered through `tpl`, for example:

```yaml
volumes:
  - name: projected-auth
    type: projected
    sources:
      - serviceAccountToken:
          path: token
      - secret:
          name: '{{ include "helpers.app.fullname" (dict "name" "secret-envs" "context" $) }}'
```
