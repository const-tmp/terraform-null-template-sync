output "config" {
  description = "Generated config"
  value       = merge([for config_name, labels in var.input : {
    for label, data in labels : "${config_name}-${label}" => data.config
  }]...)
}
