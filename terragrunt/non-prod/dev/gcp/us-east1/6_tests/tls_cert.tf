module "tls_self_signed_cert" {
  source = "github.com/tvon/tls-self-signed-cert?ref=terraform-0.12upgrade"


  name                  = var.name
  validity_period_hours = var.validity_period_hours
  ca_common_name        = var.ca_common_name
  organization_name     = var.organization_name
  common_name           = var.common_name
  dns_names             = var.dns_names
  ip_addresses          = var.ip_addresses
  download_certs        = true
}
