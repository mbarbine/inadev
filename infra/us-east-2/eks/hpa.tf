resource "kubernetes_horizontal_pod_autoscaler" "nextjs-hpa" {
  metadata {
    name      = "nextjs-hpa"
    namespace = "default"
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "nextjs-chat-service"
    }

    min_replicas = 2
    max_replicas = 10
  }
  {}
  cpu_metrics {
    resource {
      name = "cpu"
      target_average_utilization = 70
      data = {
        type = "Resource"
        name = "cpu"
        target_average_utilization = 70
      }
      resource {
        name = "cpu"

        target {
          type                 = "Utilization"
          average_utilization  = 70
        }
      }
    }
  }
