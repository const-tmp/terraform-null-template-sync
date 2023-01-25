//noinspection HILUnresolvedReference
module "nomad-client-prerequisites" {
  source  = "nullc4t/template-sync/null//modules/factory"
  version = ">= 0.1.0"

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
  source  = "nullc4t/template-sync/null//modules/factory"
  version = ">= 0.1.0"

  for_each   = module.ec2.instances["nomad-client"]

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
