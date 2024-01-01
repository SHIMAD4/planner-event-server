resource "kubernetes_persistent_volume_claim" "postgresql_planner_pvc" {
  metadata {
    name = "planner-db-pvc"
    namespace = "default"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
     }
  }
}

resource "kubernetes_config_map" "planner_db_cm" {
  metadata {
    name = "planner-db-cm"
    namespace = "default"
    labels = {
      app = "planner-db"
    }
  }

  data = {
    POSTGRES_DB       = "strapi"
    POSTGRES_USER     = "strapi"
    POSTGRES_PASSWORD = "strapi"
  }
}

resource "kubernetes_stateful_set" "planner" {
  metadata {
    name = "planner-db"
    namespace = "default"
  }
  spec {
    replicas = 1
    service_name = "planner-db-svc"
    selector {
      match_labels = {
        app = "planner-db"
      }
     }

    template {
      metadata {
        labels = {
          app = "planner-db"
        }
      }
      spec {
        volume {
          name = "db-data"
          persistent_volume_claim {
            claim_name = "planner-db-pvc"
          }
        }
	image_pull_secrets {
            name = "gitlab-docker-regcred"
        }
        container {
          name  = "planner-postgres"
          image = "postgres:14.5-alpine"
          image_pull_policy = "Always"
          port {
            container_port = 5432
          }
          env_from {
            config_map_ref {
              name = "planner-db-cm"
            }
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "planner_db_svc" {
  metadata {
    name = "planner-db-svc"
    namespace = "default"
  }
  spec {
    port {
      protocol= "TCP"
      port = 5432
      target_port = 5432
    }
    selector = {
      app = "planner-db"
    }
    type = "ClusterIP"
    session_affinity = "None"
  }
}
 
