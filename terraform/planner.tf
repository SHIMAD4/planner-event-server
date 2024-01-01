resource "kubernetes_secret" "planner" {
  metadata {
    name      = "planner"
    namespace = "default"
  }
  data = {
        APP_KEYS="97t+ivWg+wP1wdCSHQa8pQ==,REhEGKEb/spffuADaaISsQ==,bIy/30tQ54VtOn5lIGYhDA==,v/jkA+vZN7Jpii5rFcxVow=="
        API_TOKEN_SALT="ddmxYngd905IsfZ7TzX87g=="
        ADMIN_JWT_SECRET="8maHcls2JeFzzdGIDnG+7g=="
        TRANSFER_TOKEN_SALT="3NJTtYYXt4YxVhJeob8ueg=="
        JWT_SECRET="9rwIKJO8+2s5omLUqA8Yrw=="
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "planner" {
  metadata {
    name      = "planner"
    namespace = "default"
  }
  data = {
        DATABASE_HOST="planner-db-svc"
        DATABASE_NAME="strapi"
        DATABASE_USERNAME="strapi"
        DATABASE_PORT="5432"

  }
}


resource "kubernetes_deployment" "planner" {
  metadata {
    name      = "planner"
    namespace      = "default"
    annotations = {
      "deployment.kubernetes.io/revision" = "${var.build_version}"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "planner"
      }
    }
    template {
      metadata {
        labels = {
          app = "planner"
          version = var.build_version
        }
      }
      spec {
        container {
          name  = "planner"
          image = "registry.gitlab.rdclr.ru/rc-foundation/frontend/planner/planner:${var.build_version}"
          env_from {
            config_map_ref {
              name = "planner"
            }
          }
          env_from {
            secret_ref {
              name = "planner"
            }
          }
          termination_message_path   = "/dev/termination-log"
          termination_message_policy = "File"
          image_pull_policy          = "Always"
#           liveness_probe {
#            http_get {
#              path   = "/"
#              port   = "3000"
#              scheme = "HTTP"
#            }
#
#            timeout_seconds   = 5
#            period_seconds    = 6
#            success_threshold = 1
#            failure_threshold = 3
#          }
        }
        image_pull_secrets {
          name = "gitlab-docker-regcred"
        }
        restart_policy                   = "Always"
        termination_grace_period_seconds = 30
        dns_policy                       = "ClusterFirst"
        automount_service_account_token  = true
        enable_service_links             = true
      }
    }
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge = "1"
      }
    }

    revision_history_limit    = 10
  }
}


resource "kubernetes_service" "planner" {
  metadata {
    name = "planner-svc"
    namespace = "default"
  }
  spec {
    port {
      protocol    = "TCP"
      port = 1337
      target_port = 1337
    }
    selector = {
      app = "planner"
    }
    type = "ClusterIP"
    session_affinity = "None"
  }
}
