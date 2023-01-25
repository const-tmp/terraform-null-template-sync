output "instances" {
  value = {
    consul = {for label, data in module.ec2.instances["consul"] : label => "http://${data.public_ip}:8500"}
    vault  = {for label, data in module.ec2.instances["vault"] : label => "http://${data.public_ip}:8200"}
    nomad  = {for label, data in module.ec2.instances["nomad"] : label => "http://${data.public_ip}:4646"}
  }
}
