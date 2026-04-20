# nuc-common

`nuc-common` is the shared Helm library chart used by `nxs-universal-chart` and related charts.

## Annotation Helpers

The library exposes merged annotation helpers to keep rendered manifests deterministic and avoid duplicate YAML keys:

- `helpers.app.defaultHookAnnotations`
- `helpers.app.hooksAnnotations`
- `helpers.app.annotations`
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
