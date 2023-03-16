output "config" {
  description = "Generated config"
  value       = {
    connection  = var.connection
    exec_before = var.exec_before
    exec_after  = var.exec_after
    templates   = var.templates
  }
}
