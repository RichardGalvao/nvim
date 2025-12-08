-- lua/yamlls.lua

-- Common CRD Source: https://github.com/datreeio/CRDs-catalog
-- We map the schema URL to a glob pattern (e.g., all yaml files)
local schemas = {
  -- 1. Standard Kubernetes (Catch-all)
  kubernetes = "*.yaml",

  -- 2. External Secrets (Your specific request)
  ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/external-secrets.io/externalsecret_v1beta1.json"] = "templates/*.yaml",

  -- 3. "As Many As Possible" - Common Cloud Native Tools
  -- Uncomment the ones you use to enable their validation:

  -- ArgoCD (Application, AppProject)
  -- ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/application_v1alpha1.json"] = "*.yaml",

  -- Cert-Manager (Certificate, Issuer)
  -- ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/cert-manager.io/certificate_v1.json"] = "*.yaml",
  -- ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/cert-manager.io/issuer_v1.json"] = "*.yaml",

  -- Prometheus Operator (ServiceMonitor, PrometheusRule)
  -- ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/monitoring.coreos.com/servicemonitor_v1.json"] = "*.yaml",
  -- ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/monitoring.coreos.com/prometheusrule_v1.json"] = "*.yaml",

  -- Istio (VirtualService, Gateway)
  -- ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/networking.istio.io/virtualservice_v1beta1.json"] = "*.yaml",
  -- ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/networking.istio.io/gateway_v1beta1.json"] = "*.yaml",

  -- Flux CD (Kustomization, HelmRelease)
  -- ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/kustomize.toolkit.fluxcd.io/kustomization_v1.json"] = "*.yaml",
  -- ["https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/helm.toolkit.fluxcd.io/helmrelease_v2beta1.json"] = "*.yaml",
}

require("lspconfig").yamlls.setup({
  settings = {
    yaml = {
      schemaStore = {
        enable = false, -- We are manually managing schemas to avoid conflicts
        url = "",
      },
      schemas = schemas,
      -- Custom tags to ignore Helm syntax ({{ .Values }})
      customTags = {
        "!reference sequence",
        "!reference mapping",
        "!reference scalar",
        "!reference default",
        "!include sequence",
        "!include mapping",
        "!include scalar",
        "!include default",
      },
      validate = true,
      completion = true,
      hover = true,
    },
  },
})
