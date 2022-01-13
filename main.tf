terraform {
  required_version = ">= 0.14.2"
}

variable "password" {}
variable "email" {}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=11.7"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "11.7"

  cluster_name = "mcgill-chem505"
  domain       = "calculquebec.cloud"
  image        = "CentOS-7-x64-2021-11"

  instances = {
    mgmt   = { type = "p4-6gb", tags = ["puppet", "mgmt", "nfs"], count = 1 },
    login  = { type = "p2-3gb", tags = ["login", "public", "proxy"], count = 1 },
    node   = { type = "p2-3gb", tags = ["node"], count = 1 }
  }

  volumes = {
    nfs = {
      home     = { size = 100 }
      project  = { size = 50 }
      scratch  = { size = 50 }
    }
  }

  generate_ssh_key = true
  public_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1YI2Qp8zrD9OXt05h4adkI6ujU4uq+ZyAeQ7qHIBSZbAffgem5Zlb6ylUtR8nfMgfkGeE6v4eU1jE7P1dOCFkATR5VdUg164cAYCRbnAh6wFLlNpR0Deb0wupPLqXaVCfB7LVQP1NYmycUr40eYdUE9G8Ce2WxvYmsL4Y5gjh27ntdD/U8YBkg68jx53/43jBsSxHaW2oiiWCi4uG9f1YUSGPdBTGFIb/e9p0lh6nhV8u2sJ62U6eLlP+nf8F4/E6cShLgLhCyvqcQXfAl4HcsdG6zAH9vGt79up9znGJvLc8Cj/Qc6DlhMacgZl6X3U+PP6aZWNSPwDdSfCzlCIp bart@kogkog"
  ]

  nb_users = 20
  # Shared password, randomly chosen if blank
  guest_passwd = var.password
}

output "accounts" {
  value = module.openstack.accounts
}

output "public_ip" {
  value = module.openstack.public_ip
}

## Uncomment to register your domain name with CloudFlare
module "dns" {
  source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/cloudflare?ref=main"
  email            = var.email
  name             = module.openstack.cluster_name
  domain           = module.openstack.domain
  public_instances = module.openstack.public_instances
  ssh_private_key  = module.openstack.ssh_private_key
  sudoer_username  = module.openstack.accounts.sudoer.username
}

## Uncomment to register your domain name with Google Cloud
# module "dns" {
#   source           = "./dns/gcloud"
#   email            = "you@example.com"
#   project          = "your-project-id"
#   zone_name        = "you-zone-name"
#   name             = module.openstack.cluster_name
#   domain           = module.openstack.domain
#   public_instances = module.openstack.public_instances
#   ssh_private_key  = module.openstack.ssh_private_key
#   sudoer_username  = module.openstack.accounts.sudoer.username
# }

# output "hostnames" {
#   value = module.dns.hostnames
# }
