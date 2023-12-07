########################################################################
#
#                              Argo CD
#
########################################################################
resource "helm_release" "argocd" {

  count = var.enabled ? 1 : 0

  name             = "argocd-release"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "5.35.0"

  values = [
    "${file("./modules/argo_cd/values/argo.yaml")}"
  ]
}


########################################################################
#
#                     Project -> Apps of Apps
#
########################################################################
resource "kubectl_manifest" "app_project" {

  count = var.enabled ? 1 : 0

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: main-project
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  description: Testing project
  sourceRepos:
  - '*'
  destinations:
    - namespace: "*"
      server: https://kubernetes.default.svc
      name: in-cluster
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  namespaceResourceBlacklist:
    - group: ''
      kind: ResourceQuota
    - group: ''
      kind: LimitRange
    - group: ''
      kind: NetworkPolicy
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
  orphanedResources:
    warn: false
  roles:
  - name: read-only
    description: Read-only privileges to main-project
    policies:
    - p, proj:main-project:read-only, applications, get, main-project/*, allow
    groups:
    - my-oidc-group
YAML
  depends_on = [helm_release.argocd]
}

########################################################################
#
#                    Apps of Apps
#
########################################################################
resource "kubectl_manifest" "apps_of_apps" {

  count = var.enabled ? 1 : 0

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: all-apps
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
  labels:
    name:  allApps
spec:
  project: main-project
  source:
    repoURL: https://github.com/Yuxis445/Azure-EKS
    targetRevision: HEAD
    path: "modules/argo_cd/apps"
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - Validate=true
    - CreateNamespace=true 
    - PruneLast=true
    managedNamespaceMetadata:
      labels:
        managed: argocd
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
YAML
  depends_on = [helm_release.argocd]
}

resource "kubernetes_ingress_v1" "argo_cd_ingress" {
  depends_on = [helm_release.argocd]

  metadata {
    name      = "argocd"
    namespace = "argocd"
    annotations = {
      # "cert-manager.io/cluster-issuer"                    = "letsencrypt-staging"
      # "nginx.ingress.kubernetes.io/backend-protocol"      = "HTTPS"
      # "nginx.ingress.kubernetes.io/proxy-connect-timeout" = "300"
      # "nginx.ingress.kubernetes.io/proxy-read-timeout"    = "300"
      # "nginx.ingress.kubernetes.io/proxy-send-timeout"    = "300"
      "ingress.kubernetes.io/force-ssl-redirect"          = "false"
      "external-dns.alpha.kubernetes.io/hostname"         = "argocd.anontests.xyz"
      # "nginx.ingress.kubernetes.io/ssl-passthrough"       = "false"
    }
  }

  spec {
    # tls {
    #   hosts       = ["argocd.sandbox.test.internal.reecedev.us"]
    #   secret_name = "internal-reecedev"
    # }
    ingress_class_name = "nginx"
    rule {
      host = "argocd.anontests.xyz"
      http {
        path {
          path_type = "Prefix"
          path      = "/"
          backend {
            service {
              name = "argocd-release-server"
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana"
    namespace = "grafana-monitoring"
    annotations = {
      # "cert-manager.io/cluster-issuer"                    = "letsencrypt-staging"
      # "nginx.ingress.kubernetes.io/backend-protocol"      = "HTTP"
      # "nginx.ingress.kubernetes.io/proxy-connect-timeout" = "300"
      # "nginx.ingress.kubernetes.io/proxy-read-timeout"    = "300"
      # "nginx.ingress.kubernetes.io/proxy-send-timeout"    = "300"
      # "ingress.kubernetes.io/force-ssl-redirect"          = "false"
      "external-dns.alpha.kubernetes.io/hostname"         = "grafana.anontests.xyz"
      # "nginx.ingress.kubernetes.io/ssl-passthrough"       = "false"     
    }
  }

  spec {
    # tls {
    #   hosts       = ["argocd.sandbox.test.internal.reecedev.us"]
    #   secret_name = "internal-reecedev"
    # }
    ingress_class_name = "nginx"
    rule {
      host = "grafana.anontests.xyz"
      http {
        path {
          path_type = "Prefix"
          path      = "/"
          backend {
            service {
              name = "grafana-dev"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}