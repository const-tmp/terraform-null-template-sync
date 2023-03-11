resource "null_resource" "template-sync" {
  triggers = {
    exec_before = join("\n", var.exec_before)
    file        = var.template.content
    exec_after  = join("\n", var.exec_after)
  }

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
    inline = length(var.exec_before) > 0 ? var.exec_before : ["echo 'no exec_before commands'"]
  }

  provisioner "file" {
    content     = var.template.content
    destination = var.template.destination
  }

  provisioner "remote-exec" {
    inline = length(var.exec_after) > 0 ? var.exec_after : ["echo 'no exec_after commands'"]
  }
}
