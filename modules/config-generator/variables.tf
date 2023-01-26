variable "input" {
  description = "Map of configuration map for each instance type"
  type        = map(map(object({
    config = object({
      name       = string
      connection = object({
        host        = string
        user        = string
        port        = string
        password    = string
        private_key = string
        agent       = bool
      })
      exec_before = list(string)
      template    = object({
        source = string
        data   = object({
          name                 = optional(string)
          node_name            = optional(string)
          node_id              = optional(string)
          log_level            = optional(string)
          api_addr             = optional(string)
          bind_addr            = optional(string)
          cluster_addr         = optional(string)
          tcp_listener_address = optional(string)
          advertise_http       = optional(string)
          advertise_rpc        = optional(string)
          advertise_serf       = optional(string)
          retry_join           = optional(list(string))
          bootstrap_expect     = optional(number)
          acl_enabled          = optional(bool)
          vault_enabled        = optional(bool)
          vault_addr           = optional(string)
          vault_token          = optional(string)
        })
        destination = string
      })
      exec_after = list(string)
    })
  })))
}
