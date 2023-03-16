variable "connection" {
  type = object({
    host        = string
    user        = optional(string, "root")
    port        = optional(number, 22)
    password    = optional(string)
    private_key = optional(string)
    agent       = optional(string)
  })
}

variable "templates" {
  type = map(string)
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
