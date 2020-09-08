# Resource Group
variable rg_aks_name {
  type    = string
  default = "rg-akskratos"
}

variable rg_aks_location {
  type    = string
  default = "East US 2"
}

# Network Security Group
variable nsg_aks_name {
  type    = string
  default = "nsg-akskratos"
}

# Virtual Network
variable vnet_aks_name {
  type    = string
  default = "vnet-akskratos"
}

variable vnet_aks_address_space {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable vnet_aks_dns_server {
  type    = list(string)
  default = ["10.0.0.4", "10.0.0.5"]
}

# Subnet
variable subnet_aks_name {
  type    = string
  default = "subnet-akskratos"
}

variable subnet_aks_address {
  type    = string
  default = "10.0.0.0/24"
}

# AKS
variable aks_name {
  type    = string
  default = "akskratos"
}

variable aks_kubernetes_version {
  type    = string
  default = "1.16.13"
}

variable aks_default_node_pool_name {
  type    = string
  default = "agentpool"
}

variable aks_node_count_default {
  type    = number
  default = 2
}

variable aks_node_max_count {
  type    = number
  default = 5
}

variable aks_node_min_count {
  type    = number
  default = 2
}

variable aks_vm_size {
  type    = string
  default = "Standard_D2_v2"
}

# Tags
variable tags {
  type    = map(string)
  default = {
    "env"        = "dev"
    "created_by" = "terraform"
  }
}
