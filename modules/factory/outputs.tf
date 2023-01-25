output "config" {
  description = "Generated config"
  value       = {
    name        = var.name
    connection  = var.connection
    exec_before = var.exec_before
    exec_after  = var.exec_after
    template    = {
      source      = var.template.source
      data        = var.data
      destination = var.template.destination
    }
  }
}
