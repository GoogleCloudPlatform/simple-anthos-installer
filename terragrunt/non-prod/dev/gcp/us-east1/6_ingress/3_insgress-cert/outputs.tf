output "name" {
  value = google_compute_managed_ssl_certificate.managed_certificate.name
}

output "domain" {
  value = var.domain
}
