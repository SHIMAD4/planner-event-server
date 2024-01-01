provider "kubernetes" {
  host = "https://37.143.9.144:6443"
  #host = "http://127.0.0.1:8443"
  config_path = "~/.kube/config"
}

terraform {
  backend "kubernetes" {
    secret_suffix = "planner"
    load_config_file = true
    host = "https://37.143.9.144:6443"
    config_path = "~/.kube/config"
  }
}
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}


data "terraform_remote_state" "planner" {
  backend = "kubernetes"
  config = {
    secret_suffix = "planner"
    load_config_file = true
    host = "https://37.143.9.144:6443"
    config_path = "~/.kube/config"
  }
}
