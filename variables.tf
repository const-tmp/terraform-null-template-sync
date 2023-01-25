variable "template" {
  type = object({
    source      = string
    data        = any
    destination = string
  })
}

//noinspection TFIncorrectVariableType
variable "connection" {
  type = object({
    host        = string
    user        = optional(string, "root")
    port        = optional(string, 22)
    password    = string
    private_key = string
    agent       = optional(string, false)
  })

  validation {
    condition = ((var.connection.password==null && var.connection.agent==null && var.connection.private_key!=null) ||
      (var.connection.password==null && var.connection.agent!=null && var.connection.private_key==null) ||
      (var.connection.password!=null && var.connection.agent==null && var.connection.private_key==null))
    error_message = "Either password, private_key or  agent must be specified"
  }
}

variable "exec_before" {
  description = "Commands or scripts, running BEFORE sending template"
  type        = list(string)
}

variable "exec_after" {
  description = "Commands or scripts, running AFTER sending template"
  type        = list(string)
}
