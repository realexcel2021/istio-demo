resource "helm_release" "istio" {
  name = "istio-base"

  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"

  namespace        = "istio-system"
  create_namespace = true


  depends_on = [module.eks]
}

resource "helm_release" "istiod" {
  name = "istiod"

  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"

  namespace        = "istio-system"
  create_namespace = true

  depends_on = [helm_release.istio]
}


resource "helm_release" "istio-ingress" {
  name = "istio-ingress"

  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"

  namespace        = "istio-ingress"
  create_namespace = true
  wait             = false

  depends_on = [helm_release.istiod]
}

