resource "kubernetes_persistent_volume_claim" "adminer_planner_pvc" {
  metadata {
    namespace = "default"
    name = "planner-adminer"
    labels = {
      app = "adminer"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"] 
    resources {
      requests = {
        storage = "4Gi"
      }
    }
  }
}

resource "kubernetes_service" "planner_adminer_svc" {
  metadata {
    name = "planner-adminer-svc"
    namespace = "default"
    labels = {
      app = "adminer"
    }
  }
  spec {
    type = "ClusterIP"

    port {
      protocol = "TCP"
      port = 8080
      target_port = 8080
    }

    selector = {
      app = "adminer"
    }
  }
}

resource "kubernetes_deployment" "planner_adminer" {
  metadata {
    name = "planner-adminer"
    namespace = "default"
    labels = {
      app = "adminer"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "adminer"
      }
    }
    template {
      metadata {
        labels = {
          app = "adminer"
        }
      }
   
      spec { 
        container {
          name = "adminer"
          image = "adminer:latest"
          image_pull_policy = "Always"
        }
        image_pull_secrets {
          name = "gitlab-docker-regcred"
        }
        volume {
          name = "adminer-data"
          persistent_volume_claim {
            claim_name = "planner-adminer"
          }
        }
      }
    }
  }
}
        

