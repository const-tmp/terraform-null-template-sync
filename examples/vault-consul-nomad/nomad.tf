//noinspection HILUnresolvedReference
module "nomad-config" {
  source     = "../../modules/factory"

  for_each   = module.ec2.instances["nomad"]

  name       = "${each.key}:nomad"

  connection = {
    host        = each.value.public_ip
    agent       = true
    password    = null
    private_key = null
  }

  exec_before = []

  template    = {
    source      = "${path.root}/../../../config/nomad/server.hcl"
    destination = "/etc/nomad.d/nomad.hcl"
  }

  data = {
    name             = each.key
    bootstrap_expect = length(module.ec2.instances["nomad"])
    retry_join       = [for _, v in module.ec2.instances["nomad"] : v.public_ip]
    bind_addr        = each.value.public_ip
    advertise_http   = each.value.public_ip
    advertise_rpc    = each.value.public_ip
    advertise_serf   = each.value.public_ip
    acl_enabled      = false
    vault_enabled    = false
    vault_token      = ""
  }

  exec_after = [
    "ufw disable",
    "systemctl daemon-reload",
    "systemctl enable nomad.service",
    "systemctl restart nomad.service",
  ]
}
