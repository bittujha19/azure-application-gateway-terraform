variable "location" {
  description = "North Europe"
  default = "North Europe"
}

variable "virtual_network_name" {
  default = ""
}

variable "resource_group_name" {
  default = ""
}

variable "network_resource_group_name" {
  default = ""
}


variable "subnet_id" {
  default = ""
}

variable "sku_name" {
  default = ""
}

variable "sku_tier" {
  default = ""
}

variable "sku_capacity" {
  default = ""
}

variable "site" {
  default     = ""
  description = "An optional prefix to use in naming schemes"
}

variable "environment" {
  default     = ""
  description = "An environment might have implications on naming schemes, or deployment options."
}

variable "application" {
  default     = ""
  description = "Application name for naming schemes, or deployment options."
}

variable "network_security_group_id" {
  default = ""
}

variable "tags" {
  type    = map
  default = {
    "CC Code" = "00000"
    "Project" = "TESTING-PROJECT"
    "Environment" = ""
  }
  description = "A mapping of tags to assign to the resource. For instance business stakeholders, or who pays for it?"
}

variable "initial_count" {
  description = "Specify the number of vm instances"
  default     = "1"
}

variable "private_ip_address_allocation" {
  default = "Static"
}

variable "private_ip_address" {
  default = ""
}


variable "frontend_ip_configuration_name" {
  default = ""
}

variable "backend_address_pool" {
  type = list(string)
  default = []
}

variable "backend_http_settings" {
  type = list(object({
    name                  = string
    cookie_based_affinity = string
    port                  = number
    path                  = string
    protocol              = string
    request_timeout       = number
    host_name             = string
    probe_name            = string
  }))
  default = []      
}


variable "route_config" {
  type = list(object({
    name = string 
    port = number
    protocol = string
    default_backend = string
    default_httpsettings = string
    route_rule = map(list(string))
  }))
  default =[]
}

variable "probe" {
  type = list(object({
          host                                      = string
          interval                                  = number 
          minimum_servers                           = number
          name                                      = string 
          path                                      = string 
          pick_host_name_from_backend_http_settings = bool
          // port                                      = 0 
          protocol                                  = string
          timeout                                   = number
          unhealthy_threshold                       = number
          status_code                               = list(string)
  }))
  default = []      
}
