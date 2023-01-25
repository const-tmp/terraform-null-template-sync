//noinspection HILUnresolvedReference
locals {
  v1 = [
    {for k, v in module.nomad-client-prerequisites : k=>v.data},
    {for k, v in module.consul-config : k=>v.data},
    {for k, v in module.vault-config : k=>v.data},
    {for k, v in module.nomad-config : k=>v.data},
    {for k, v in module.nomad-client-config : k=>v.data},
    {for k, v in module.consul-agent-config : k=>v.data},
    {for k, v in module.consul-dns-forwarding-config : k=>v.data},
  ]

  v2 = flatten([for map in local.v1 : [for label, data in map : { id = data.name, data = data }]])

  config = {for i in local.v2 : i.id=>i.data}

  consul_agent_targets = flatten([
    for name, batch in module.ec2.instances : [
      for label, data in batch : {
        label = label
        data  = data
      }
    ] if name != "consul"
  ])
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

//noinspection HILUnresolvedReference
module "nomad-client-prerequisites" {
  source     = "../../modules/factory"
  for_each   = module.ec2.instances["nomad-client"]
  name       = "${each.key}:nomad-client-prerequisites"
  connection = {
    host        = each.value.public_ip
    agent       = true
    password    = null
    private_key = null
  }
  exec_before = []
  template    = {
    source      = "${path.root}/../../../config/nomad/cni.cfg"
    destination = "/etc/sysctl.d/local.conf"
  }
  data       = {}
  exec_after = [
    "ufw disable",
    "curl -L -o cni-plugins.tgz \"https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)\"-v1.0.0.tgz",
    "mkdir -p /opt/cni/bin",
    "tar -C /opt/cni/bin -xzf cni-plugins.tgz",
    "echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables",
    "echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables",
    "echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables",
    "service procps force-reload",
  ]
}

//noinspection HILUnresolvedReference
module "nomad-client-config" {
  for_each   = module.ec2.instances["nomad-client"]
  source     = "../../modules/factory"
  name       = "${each.key}:nomad-client"
  connection = {
    host        = each.value.public_ip
    agent       = true
    password    = null
    private_key = null
  }
  exec_before = []
  template    = {
    source      = "${path.root}/../../../config/nomad/client.hcl"
    destination = "/etc/nomad.d/nomad.hcl"
  }
  data = {
    name          = each.key
    retry_join    = [for _, v in module.ec2.instances["nomad"] : v.public_ip]
    bind_addr     = each.value.public_ip
    vault_enabled = false
  }
  exec_after = [
    "mkdir -p /opt/nomad/data/host-volumes/wp-server",
    "mkdir -p /opt/nomad/data/host-volumes/wp-runner",
    "systemctl daemon-reload",
    "systemctl enable nomad.service",
    "systemctl restart nomad.service",
  ]
}

//noinspection HILUnresolvedReference
module "consul-agent-config" {
  for_each   = {for i in local.consul_agent_targets : i.label=>i.data}
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
