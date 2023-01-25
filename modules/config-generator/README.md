# terraform-null-template-sync-config-generator
Auto-updatable templates config generator
## Example
```
module "vault-config" {
  source     = "../../modules/factory"
  
  for_each   = module.ec2.instances["vault"]
  
  name       = "${each.key}:vault"
  ...
}

module "config_generator" {
  source = "../../modules/config-generator"

  input  = {
    ...
    vault-config                 = module.vault-config
    consul-config                = module.consul-config
    nomad-config                 = module.nomad-config
    ...
  }
}

module "config" {
  source      = "../.."

  for_each    = module.config_generator.config
  
  connection  = each.value.connection
  exec_before = each.value.exec_before
  template    = each.value.template
  exec_after  = each.value.exec_after
}
```