//noinspection HILUnresolvedReference
module "consul-agent-config" {
  source     = "../../modules/factory"

  for_each   = {
    for i in flatten([
      for name, batch in module.ec2.instances : [
        for label, data in batch : {
          label = label
          data  = data
        }
      ] if name != "consul"
    ]) : i.label=>i.data
  }

  name       = "${each.key}:consul-agent"

  connection = {
    host        = each.value.public_ip
    agent       = true
    password    = null
    private_key = null
  }

  exec_before = []

  template    = {
    source      = "${path.root}/../../../config/consul/client.hcl"
    destination = "/etc/consul.d/consul.hcl"
  }

  data = {
    node_name  = each.key
    retry_join = [for _, v in module.ec2.instances["consul"] : v.public_ip]
    bind_addr  = each.value.public_ip
    log_level  = upper("debug")
  }

  exec_after = [
    "ufw disable",
    "systemctl daemon-reload",
    "systemctl enable consul.service",
    "systemctl restart consul.service",
  ]
}
