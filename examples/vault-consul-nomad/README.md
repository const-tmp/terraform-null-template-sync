# vault-consul-nomad
Deploy hashistack to VM using `terraform-null-template-sync`
## Usage
```
terraform init
terraform apply
```
### Result
```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

instances = {
  "consul" = {
    "consul-0" = "http://xx.xx.xxx.xxx:8500"
  }
  "nomad" = {
    "nomad-0" = "http://xx.xx.xxx.xxx:4646"
  }
  "vault" = {
    "vault-0" = "http://xx.xx.xxx.xxx:8200"
  }
}

```
