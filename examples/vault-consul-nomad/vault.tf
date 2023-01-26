//noinspection HILUnresolvedReference
module "vault-config" {
  source  = "nullc4t/template-sync/null//modules/factory"
  version = ">= 0.1.0"

  for_each   = module.ec2.instances["vault"]

  name       = "${each.key}:vault"

  connection = {
    host        = each.value.public_ip
    agent       = true
    password    = null
    private_key = null
  }

  exec_before = []

  template    = {
    source      = "${path.root}/../../../config/vault/server.hcl"
    destination = "/etc/vault.d/vault.hcl"
  }

  data = {
    node_id              = each.key
    cluster_addr         = each.value.private_ip
    api_addr             = each.value.private_ip
    tcp_listener_address = each.value.private_ip
    retry_join           = [for _, v in module.ec2.instances["vault"] : v.private_ip]
  }

  exec_after = [
    "ufw disable",
    "systemctl daemon-reload",
    "systemctl enable vault.service",
    "systemctl restart vault.service",
  ]
}
