// terraform {
//   backend "azurerm" {
//     storage_account_name = "storageaccountname"
//     container_name       = "terraform"
//     resource_group_name  = "resourcegroupname"
//     key                  = "xxxxxxxxxxxx.terraform.tfstate"
//   }
// }

module "agw" {
  source = "../modules"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${var.virtual_network_name}"
  application = "${var.application}"
  tags = var.tags
  site = "${var.site}"
  location = "${var.location}"
  environment = "${var.environment}"
  initial_count = "${var.initial_count}"
  subnet_id = "${var.subnet_id}"
  network_resource_group_name = "${var.network_resource_group_name}"
  sku_name = "${var.sku_name}"
  sku_tier = "${var.sku_tier}"
  sku_capacity = "${var.sku_capacity}"
  private_ip_address_allocation = "${var.private_ip_address_allocation}"
  private_ip_address = "${var.private_ip_address}"
  frontend_ip_configuration_name = "${var.frontend_ip_configuration_name}"
  backend_address_pool = "${var.backend_address_pool}"
  backend_http_settings = "${var.backend_http_settings}"
  route_config = "${var.route_config}"
  probe = "${var.probe}"
}






