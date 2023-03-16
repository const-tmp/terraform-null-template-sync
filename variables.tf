variable "templates" {
  type = map(string)
}

variable "connection" {
  type = object({
    host        = string
    user        = optional(string, "root")
    port        = optional(number, 22)
    password    = optional(string)
    private_key = optional(string)
    agent       = optional(string)
  })

  validation {
    condition = (
      (var.connection.password==null && var.connection.agent==null && var.connection.private_key!=null) ||
      (var.connection.password==null && var.connection.agent!=null && var.connection.private_key==null) ||
      (var.connection.password!=null && var.connection.agent==null && var.connection.private_key==null)
    )
    error_message = "Either password, private_key or  agent must be specified"
  }
}

variable "exec_before" {
  description = "Commands or scripts, running BEFORE sending template"
  type        = list(string)
  default     = []
}

variable "exec_after" {
  description = "Commands or scripts, running AFTER sending template"
  type        = list(string)
  default     = []
}
