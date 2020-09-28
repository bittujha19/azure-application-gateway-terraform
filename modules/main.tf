provider "azurerm" {
  features {}
}

data "azurerm_subnet" "example" {
  name                 = var.subnet_id
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.network_resource_group_name
}

output "subnet_id" {
  value = data.azurerm_subnet.example.id
}

data "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  resource_group_name = var.network_resource_group_name
}

// resource "azurerm_public_ip" "example" {
//   name                = "example-pip"
//   resource_group_name = var.resource_group_name
//   location            = var.location
//   allocation_method   = "Dynamic"
// }

locals {
// breaking up route_config 
  basic_route_config = flatten([for cfg in var.route_config: cfg if length(cfg.route_rule) == 0 && length(cfg.default_backend)>0])
  urlbased_route_config = flatten([for cfg in var.route_config: cfg if length(cfg.route_rule) > 0 && length(cfg.default_backend)>0])
}

resource "azurerm_application_gateway" "network" {
  count               = var.initial_count 
  name                = "${var.site}-alb-${var.environment}-${var.application}-00${count.index+1}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = data.azurerm_subnet.example.id
  }

  dynamic "frontend_port" {
    for_each = var.route_config
    content {
      name = "port_${frontend_port.value["port"]}"
      port = frontend_port.value["port"]
    }
  }

  // frontend_ip_configuration {
  //   name                 = local.frontend_ip_configuration_name
  //   public_ip_address_id = azurerm_public_ip.example.id
  // }

  frontend_ip_configuration {
    name                          = var.frontend_ip_configuration_name
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address
    subnet_id                     = data.azurerm_subnet.example.id
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pool
    content {
      name = backend_address_pool.value
    }

  } 

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                  = backend_http_settings.value["name"] 
      cookie_based_affinity = backend_http_settings.value["cookie_based_affinity"] 
      port                  = backend_http_settings.value["port"] 
      protocol              = backend_http_settings.value["protocol"] 
      request_timeout       = backend_http_settings.value["request_timeout"] 
      host_name             = backend_http_settings.value["host_name"]
      probe_name            = backend_http_settings.value["probe_name"]
    }
  }

  dynamic "http_listener" {
    for_each = var.route_config
    content {
      name                           = http_listener.value["name"]
      frontend_ip_configuration_name = var.frontend_ip_configuration_name
      frontend_port_name             = "port_${http_listener.value["port"]}"
      protocol                       = http_listener.value["protocol"]
    }
  }

  redirect_configuration {  
          name                 = "http-listener-rr"   
          redirect_type        = "Permanent"      
          target_listener_name = "https-listener"   
  }


  dynamic "request_routing_rule" {
    for_each = local.basic_route_config 
      content {
          http_listener_name = request_routing_rule.value["name"]     
          name               = "${request_routing_rule.value["name"]}-rr"   
          rule_type          = "Basic" 
          backend_address_pool_name = request_routing_rule.value["default_backend"]
          backend_http_settings_name = request_routing_rule.value["default_httpsettings"]
        }
  }

  dynamic "request_routing_rule" {
    for_each = local.urlbased_route_config 
      content {
          http_listener_name = request_routing_rule.value["name"]     
          name               = "${request_routing_rule.value["name"]}-rr"   
          rule_type          = "PathBasedRouting"
          url_path_map_name  = "${request_routing_rule.value["name"]}-rule"
        }
  } 

  dynamic "url_path_map" {
    for_each = local.urlbased_route_config 
    content {
      default_backend_address_pool_name = url_path_map.value["default_backend"]
      default_backend_http_settings_name = url_path_map.value["default_httpsettings"]  
      name                               = "${url_path_map.value["name"]}-rule"
      dynamic "path_rule" { 
      for_each = url_path_map.value["route_rule"]
      content {
              backend_address_pool_name  = path_rule.key  
              backend_http_settings_name = url_path_map.value["default_httpsettings"]    
              name                       = "${path_rule.key}-rule"  
              paths                      = path_rule.value
            }
      } 
    } 
  }

  dynamic "probe" {
    for_each = var.probe
    content {
          host                                      = probe.value["host"]
          interval                                  = probe.value["interval"]
          minimum_servers                           = probe.value["minimum_servers"] 
          name                                      = probe.value["name"]
          path                                      = probe.value["path"] 
          pick_host_name_from_backend_http_settings = probe.value["pick_host_name_from_backend_http_settings"]
          // port                                      = 0 
          protocol                                  = probe.value["protocol"] 
          timeout                                   = probe.value["timeout"]
          unhealthy_threshold                       = probe.value["unhealthy_threshold"]
          match {
              status_code = probe.value["status_code"] 
            }
    }
  }

  tags = var.tags

}
