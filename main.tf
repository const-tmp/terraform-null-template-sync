resource "null_resource" "exec-before" {
  triggers = merge(
    {
      exec_before = join("\n", var.exec_before)
      exec_after  = join("\n", var.exec_after)
    },
    {for k, v in var.templates : k => v},
  )

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
}

resource "null_resource" "template-sync" {
  depends_on = [null_resource.exec-before]

  for_each = var.templates

  triggers = merge(
    {
      exec_before = join("\n", var.exec_before)
      exec_after  = join("\n", var.exec_after)
    },
    {for k, v in var.templates : k => v},
  )

  connection {
    type        = "ssh"
    host        = var.connection.host
    port        = var.connection.port
    user        = var.connection.user
    password    = var.connection.password
    private_key = var.connection.private_key
    agent       = var.connection.agent
  }

  provisioner "file" {
    content     = each.value
    destination = each.key
  }
}

resource "null_resource" "exec-after" {
  depends_on = [null_resource.template-sync]

  triggers = merge(
    {
      exec_before = join("\n", var.exec_before)
      exec_after  = join("\n", var.exec_after)
    },
    {for k, v in var.templates : k => v},
  )

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
    inline = length(var.exec_after) > 0 ? var.exec_after : ["echo 'no exec_after commands'"]
  }
}
