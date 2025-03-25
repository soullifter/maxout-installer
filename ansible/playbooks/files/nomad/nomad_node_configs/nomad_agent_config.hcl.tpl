data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

advertise {
  http = "$CURR_NOMAD_SERVER_PRIVATE_IP"
  rpc  = "$CURR_NOMAD_SERVER_PRIVATE_IP"
  serf = "$CURR_NOMAD_SERVER_PRIVATE_IP"
}

server {
  enabled = $SERVER_ENABLED
  bootstrap_expect = $BOOTSTRAP_EXPECT
  server_join {
    retry_join = $NOMAD_SERVER_PRIVATE_IPS
    retry_max = 10
    retry_interval = "15s"
  }
  default_scheduler_config {
    preemption_config {
      batch_scheduler_enabled    = true
      system_scheduler_enabled   = true
      service_scheduler_enabled  = false
      sysbatch_scheduler_enabled = false
    }
    memory_oversubscription_enabled = true
  }
}

client {
  $NODE_CLASS_STRING
  node_pool = "$NODE_POOL"
  enabled = $CLIENT_ENABLED
  server_join {
    retry_join = $NOMAD_SERVER_PRIVATE_IPS
    retry_max = 10
    retry_interval = "15s"
  }

}

consul {
  address = "127.0.0.1:8500"
}

acl {
  enabled = true
}

limits {
  http_max_conns_per_client = 0
  rpc_max_conns_per_client = 0
}

plugin "docker" {
  config {
    gc {
      image = false
    }
    volumes {
      enabled = true
    }
  }
}