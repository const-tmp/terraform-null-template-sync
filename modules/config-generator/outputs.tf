locals {
  tmp = flatten([
    for _, v in var.input : [
      for label, data in v : {
        id = data.config.name
        data = data.config
      }
    ]
  ])
}

output "config" {
  description = "Generated config"
  value       = {for i in local.tmp : i.id=>i.data}
}
