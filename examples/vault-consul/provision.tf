//noinspection HILUnresolvedReference
locals {
  v1 = [
    {for k, v in module.consul-config : k=>v.data},
    {for k, v in module.vault-config : k=>v.data},
    {for k, v in module.vault-consul-agent-config : k=>v.data},
    {for k, v in module.consul-dns-forwarding-config : k=>v.data},
  ]

  v2 = flatten([for map in local.v1 : [for label, data in map : { id = data.name, data = data }]])

  config = {for i in local.v2 : i.id=>i.data}
}

//noinspection HILUnresolvedReference
module "config" {
  source      = "../.."
  for_each    = local.config
  connection  = each.value.connection
  exec_before = each.value.exec_before
  template    = each.value.template
  exec_after  = each.value.exec_after
}

//noinspection HILUnresolvedReference
module "vault-config" {
  source     = "../../modules/factory"
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
    cluster_addr         = each.value.public_ip
    api_addr             = each.value.public_ip
    tcp_listener_address = each.value.public_ip
    retry_join           = [for _, v in module.ec2.instances["vault"] : v.public_ip]
  }
  exec_after = [
    "ufw disable",
    "systemctl daemon-reload",
    "systemctl enable vault.service",
    "systemctl restart vault.service",
  ]
}

//noinspection HILUnresolvedReference
module "vault-consul-agent-config" {
  for_each   = module.ec2.instances["vault"]
  source     = "../../modules/factory"
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

//noinspection HILUnresolvedReference
module "consul-dns-forwarding-config" {
  source     = "../../modules/factory"
  for_each   = module.ec2.all_instances
  name       = "${each.key}:consul-dns-forwarding"
  connection = {
    host        = each.value.public_ip
    agent       = true
    password    = null
    private_key = null
  }
  exec_before = [
    "mkdir -p /etc/systemd/resolved.conf.d/",
  ]
  template = {
    source      = "${path.root}/../../../config/consul/dns-forwarding.conf"
    destination = "/etc/systemd/resolved.conf.d/consul.conf"
  }
  data       = {}
  exec_after = [
    "systemctl restart systemd-resolved",
  ]
}

output "config" {
  value = local.config
}