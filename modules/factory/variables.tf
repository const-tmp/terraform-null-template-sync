//noinspection TFIncorrectVariableType
variable "connection" {
  type = object({
    host        = string
    user        = optional(string, "root")
    port        = optional(string, 22)
    password    = string
    private_key = string
    agent       = bool
  })
}

variable "name" {
  description = "Unique descriptor"
  type        = string
}

variable "data" {
  description = "Data for template rendering"
  type        = any
}

variable "template" {
  type = object({
    source      = string
    destination = string
  })
}

variable "exec_before" {
  description = "Commands or scripts, running BEFORE sending template"
  type        = list(string)
}

variable "exec_after" {
  description = "Commands or scripts, running AFTER sending template"
  type        = list(string)
}
