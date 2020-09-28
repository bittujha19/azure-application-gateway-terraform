variable "location" {
  description = "North Europe"
  default = "North Europe"
}

variable "virtual_network_name" {
  default = "wxyz-vnet-m-001"
}

variable "resource_group_name" {
  default = "wxyz-rg-datanonprod-testing-002"
}

variable "network_resource_group_name" {
  default = "wxyz-rg-network"
}


variable "subnet_id" {
  default = "wxyz-subn-testing-stg-001"
}

variable "sku_name" {
  default = "Standard_Small"
}

variable "sku_tier" {
  default = "Standard"
}

variable "sku_capacity" {
  default = "2"
}

variable "site" {
  default     = "wxyz"
  description = "An optional prefix to use in naming schemes"
}

variable "environment" {
  default     = "testing"
  description = "An environment might have implications on naming schemes, or deployment options."
}

variable "application" {
  default     = "testing"
  description = "Application name for naming schemes, or deployment options."
}

variable "network_security_group_id" {
  default = ""
}

variable "tags" {
  type    = map
  default = {
    "CC Code" = "00000"
    "Project" = "TEST-PROJECT"
    "Environment" = "sandbox"
  }
  description = "A mapping of tags to assign to the resource. For instance business stakeholders, or who pays for it?"
}

variable "initial_count" {
  description = "Specify the number of vm instances"
  default     = "1"
}

variable "user_object_id" {
  default = ""
}

variable "objectpermission_map" {
  type = list(object({
    object_id = string 
    permissions = string
  }))
  default = []
}

variable "private_ip_address_allocation" {
  default = "Static"
}

variable "private_ip_address" {
  default = "10.1.1.8"
}


variable "frontend_ip_configuration_name" {
  default = "appGatewayPrivateFrontendIp"
}

variable "backend_address_pool" {
  type = list(string)
  default = ["webserver", "apiserver", "data_analytics_server_pool"]
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
  default = [
    {
      name                  = "httpsettings"
      cookie_based_affinity = "Disabled"
      port                  = 8080
      path                  = "string"
      protocol              = "Http"
      request_timeout       = 120
      host_name             = "mono-api-server.terraform.dev"
      probe_name            = "backend-probe"
    },
    {
      name                  = "frontendserversetting"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      port                  = 3000
      protocol              = "Http"
      request_timeout       = 120
      host_name             = "mono-api-server.terraform.dev"
      probe_name            = "frontend-probe"
    },
  ]      
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
  default =[
    {
      name="http-listener"
      port=80
      protocol = "Http"
      default_backend = "webserver"
      default_httpsettings = "httpsettings"
      route_rule = {}
    },
    {
      name="https-listener"
      port=4443
      protocol = "Http"
      default_backend = "webserver"
      default_httpsettings = "httpsettings"
      route_rule = {
        "webserver" = ["/MonoStrategy", "/MonoStrategy/*"]
        "apiServer" = ["/MonoStrategyLibrary", "/MonoStrategyLibrary/*"] 
      }
    },
    {
      name="https-pla-listner"
      port=8080
      protocol="Http"
      default_backend = ""
      default_httpsettings = ""
      route_rule = {}
    },   
    {
      name="https-frontend"
      port=3000
      protocol = "Http"
      default_backend = "apiserver"
      default_httpsettings = "frontendserversetting"
      route_rule = {
       "apiserver" = ["/*",]
      }
    }, 
  ]
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
  default = [
    {
          host                                      = "mono-api-server.terraform.dev"
          interval                                  = 30 
          minimum_servers                           = 0 
          name                                      = "backend-probe" 
          path                                      = "/MonoStrategy" 
          pick_host_name_from_backend_http_settings = false 
          // port                                      = 0 
          protocol                                  = "Http" 
          timeout                                   = 30 
          unhealthy_threshold                       = 3
          status_code                               = ["200-404"]
    },
    {
          host                                      = "mono-api-server.terraform.dev"
          interval                                  = 30 
          minimum_servers                           = 0 
          name                                      = "frontend-probe" 
          path                                      = "/" 
          pick_host_name_from_backend_http_settings = false 
          // port                                      = 0 
          protocol                                  = "Http" 
          timeout                                   = 30 
          unhealthy_threshold                       = 3
          status_code                               = ["200-404"]
    },
    {
          host                                      = ""
          interval                                  = 30 
          minimum_servers                           = 0 
          name                                      = "platformanalytis-probe" 
          path                                      = "/" 
          pick_host_name_from_backend_http_settings = true 
          // port                                      = 0 
          protocol                                  = "Http" 
          timeout                                   = 30 
          unhealthy_threshold                       = 3 
          status_code                               = ["200-399"]
    },
  ]      
}
