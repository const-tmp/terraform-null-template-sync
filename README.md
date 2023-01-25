# terraform-null-template-sync
Auto-updatable templates
## Example
See [full example](https://github.com/nullc4t/terraform-null-template-sync/tree/main/examples/vault-consul-nomad)
```
module "vault-config" {
  source  = "nullc4t/template-sync/null//modules/factory"
  version = ">= 0.1.0"
  
  for_each   = module.ec2.instances["vault"]
  
  name       = "${each.key}:vault"
  ...
}

module "config_generator" {
  source  = "nullc4t/template-sync/null//modules/config-generator"
  version = ">= 0.1.0"

  input  = {
    ...
    vault-config                 = module.vault-config
    consul-config                = module.consul-config
    nomad-config                 = module.nomad-config
    ...
  }
}

module "config" {
  source  = "nullc4t/template-sync/null"
  version = ">= 0.1.0"

  for_each    = module.config_generator.config
  
  connection  = each.value.connection
  exec_before = each.value.exec_before
  template    = each.value.template
  exec_after  = each.value.exec_after
}
```
