//noinspection HILUnresolvedReference
module "consul-dns-forwarding-config" {
  source  = "nullc4t/template-sync/null//modules/factory"
  version = ">= 0.1.0"

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
