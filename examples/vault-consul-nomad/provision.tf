module "config_generator" {
  source  = "nullc4t/template-sync/null//modules/config-generator"
  version = ">= 0.1.0"

  input  = {
    nomad-client-prerequisites   = module.nomad-client-prerequisites
    consul-config                = module.consul-config
    vault-config                 = module.vault-config
    nomad-config                 = module.nomad-config
    nomad-client-config          = module.nomad-client-config
    consul-agent-config          = module.consul-agent-config
    consul-dns-forwarding-config = module.consul-dns-forwarding-config
  }
}

//noinspection HILUnresolvedReference
module "config" {
  source  = "nullc4t/template-sync/null"
  version = ">= 0.1.0"

  for_each    = module.config_generator.config
  connection  = each.value.connection
  exec_before = each.value.exec_before
  template    = each.value.template
  exec_after  = each.value.exec_after
}
