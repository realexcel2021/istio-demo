###############################################
# Create namespace and enable istio to inject side car pods

resource "kubectl_manifest" "app" {
  yaml_body = <<YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: boutique-app
      labels:
        istio-injection: enabled

YAML

  depends_on = [module.eks]
}

#################################################
# Apply application's helm chart

resource "helm_release" "app" {
  name  = "boutique-app"
  chart = "./helm-chart"

  namespace  = "boutique-app"
  depends_on = [helm_release.istio, helm_release.istio-ingress, helm_release.istiod, kubectl_manifest.app]
}

################################################
# Create Istio Gateway

resource "kubectl_manifest" "gateway" {
  depends_on = [helm_release.istio, helm_release.istio-ingress, helm_release.istiod, kubectl_manifest.app, helm_release.app]
  yaml_body  = <<YAML

    apiVersion: networking.istio.io/v1alpha3
    kind: Gateway
    metadata:
      name: frontend-gateway
      namespace: boutique-app
    spec:
      selector:
        istio: ingress
      servers:
      - port:
          number: 80
          name: http
          protocol: HTTP
        hosts:
          - "*"
YAML
}