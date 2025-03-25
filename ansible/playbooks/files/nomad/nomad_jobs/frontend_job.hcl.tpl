job "maxout-frontend" {
  datacenters = ["dc1"]

  type = "service"

  group "maxout-frontend" {
    count = "1"

    network {
      port "maxout-frontend-http" {
        to = 80
      }
    }

    service {
      name     = "maxout-frontend"
      port     = "maxout-frontend-http"
      provider = "consul"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.maxout-frontend-http.rule=(PathPrefix(`/`))",
        "traefik.http.routers.maxout-frontend-http.priority=1"
      ]

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "server" {
      driver = "docker"

      env {
        VITE_API_URL                            = "{{ PUBLIC_SERVER_URL }}/api"
        WDS_SOCKET_PORT                         = 0
      }

      config {
          image              = "{{ DOCKER_REGISTRY_NAME }}/{{ "maxout_frontend" if IMAGE_BRANCH == "prod" else "maxout_frontend_" ~ IMAGE_BRANCH }}:{{ MAXOUT_VERSION }}"
          image_pull_timeout = "15m"
          ports              = ["maxout-frontend-http"]
          auth {
            username       = "{{ DOCKER_REGISTRY_USERNAME }}"
            password       = "{{ DOCKER_REGISTRY_PASSWORD }}"
            server_address = "{{ DOCKER_REGISTRY_NAME }}"
          }
      }

      resources {
        cpu        = 500
        memory     = 2000
        memory_max = 4000
      }
    }
  }
}
