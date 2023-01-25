locals {
  file = templatefile(var.template.source, var.template.data)
}

resource "null_resource" "template-sync" {
  triggers = { file = local.file }

  connection {
    type        = "ssh"
    host        = var.connection.host
    port        = var.connection.port
    user        = var.connection.user
    password    = var.connection.password
    private_key = var.connection.private_key
    agent       = var.connection.agent
  }

  provisioner "remote-exec" {
    inline = length(var.exec_before) > 0 ? var.exec_before : ["echo 'no commands in exec_before'"]
  }

  provisioner "file" {
    content     = local.file
    destination = var.template.destination
  }

  provisioner "remote-exec" {
    inline = length(var.exec_after) > 0 ? var.exec_after : ["echo 'no commands in exec_after'"]
  }
}
