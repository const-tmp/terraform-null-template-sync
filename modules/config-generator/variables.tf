variable "input" {
  description = "Map of configuration map for each instance type"
  type        = map(map(object({
    config = object({
      connection = object({
        host        = string
        user        = string
        port        = string
        password    = string
        private_key = string
        agent       = bool
      })
      exec_before = list(string)
      template    = map(string)
      exec_after  = list(string)
    })
  })))
}
