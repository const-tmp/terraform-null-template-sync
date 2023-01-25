//noinspection HILUnresolvedReference
module "consul-config" {
  source     = "../../modules/factory"

  for_each   = module.ec2.instances["consul"]

  name       = "${each.key}:consul"

  connection = {
    host        = each.value.public_ip
    agent       = true
    password    = null
    private_key = null
  }

  exec_before = []

  template    = {
    source      = "${path.root}/../../../config/consul/server.hcl"
    destination = "/etc/consul.d/consul.hcl"
  }

  data = {
    node_name        = each.key
    bootstrap_expect = length(module.ec2.instances["consul"])
    retry_join       = [for _, v in module.ec2.instances["consul"] : v.public_ip]
    bind_addr        = each.value.public_ip
    log_level        = upper("debug")
    acl_enabled      = false
    vault_enabled    = false
    vault_token      = ""
    vault_addr       = ""
  }

  exec_after = [
    "ufw disable",
    "systemctl daemon-reload",
    "systemctl enable consul.service",
    "systemctl restart consul.service",
  ]
}
