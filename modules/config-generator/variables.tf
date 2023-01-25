variable "input" {
  description = "Map of configuration map for each instance type"
#  type        = map(map(object({
#    name       = string
#    connection = object({
#      host        = string
#      user        = optional(string, "root")
#      port        = optional(string, 22)
#      password    = string
#      private_key = string
#      agent       = bool
#    })
#    exec_before = list(string)
#    template    = object({
#      source      = string
#      destination = string
#    })
#    data       = any
#    exec_after = list(string)
#  })))
}
