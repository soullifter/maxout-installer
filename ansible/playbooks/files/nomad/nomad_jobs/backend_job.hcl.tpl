job "maxout-backend" {
  datacenters = ["dc1"]
  type        = "service"

  group "maxout-backend" {
    count = "1"

    scaling {
      enabled = true
      min     = 1
      max     = 5
    }

    network {
      port "maxout-backend-http" {
        to = 8000
      }
    }

    service {
      name     = "maxout-backend"
      port     = "maxout-backend-http"
      provider = "consul"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.maxout-backend-http.rule=(PathPrefix(`/api`))",
        "traefik.http.routers.maxout-backend-http.priority=10",
        "traefik.http.middlewares.request-size-limit.buffering.maxRequestBodyBytes=524288000",
        "traefik.http.middlewares.request-size-limit.buffering.memRequestBodyBytes=1048576",
        "traefik.http.routers.maxout-backend-http.middlewares=request-size-limit",
      ]

      check {
        name     = "maxout Backend TCP Check"
        type     = "tcp"
        port     = "maxout-backend-http"
        interval = "5s"
        timeout  = "2s"

        check_restart {
          limit = 1
          grace = "1m"
        }
      }
    }

    task "backend" {
      driver = "docker"

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
        change_mode = "restart"
        data        = <<EOF
{% raw %}
{{- with nomadVar "nomad/jobs" -}}
DB_URI = {{ .db_uri }}
OPENAI_API_KEY = {{ .openai_api_key }}
GEMINI_API_KEY = {{ .gemini_api_key }}
JWT_SECRET = {{ .jwt_secret }}
SENDGRID_API_KEY = {{ .sendgrid_api_key }}
{{- end -}}
{% endraw %}
EOF
      }

      env {
        PUBLIC_URL                    = "{{ PUBLIC_SERVER_URL }}"
        ADMIN_PASSWORD                = "{{ ADMIN_PASSWORD }}"
        ADMIN_MAIL                    = "{{ ADMIN_MAIL }}"
        ADMIN_NAME                    = "{{ ADMIN_NAME }}"
        ADMIN_NUMBER                  = "{{ ADMIN_NUMBER }}"
        ADMIN_IRID                    = "{{ ADMIN_IRID }}"
        NUM_USERS                     = "{{ NUM_USERS }}"
      }

      config {
        image              = "{{ DOCKER_REGISTRY_NAME }}/{{ "maxout_backend" if IMAGE_BRANCH == "prod" else "maxout_backend_" ~ IMAGE_BRANCH }}:{{ MAXOUT_VERSION }}"
        image_pull_timeout = "45m"
        ports              = ["maxout-backend-http"]
        auth {
          username       = "{{ DOCKER_REGISTRY_USERNAME }}"
          password       = "{{ DOCKER_REGISTRY_PASSWORD }}"
          server_address = "{{ DOCKER_REGISTRY_NAME }}"
        }
      }

      resources {
        cores    = 2
        memory = 2048
        memory_max = 4096
      }
    }

    restart {
      attempts = 1
      interval = "10m"
      delay    = "2s"
      mode     = "fail"
    }
  }
}