resource "google_compute_managed_ssl_certificate" "managed_certificate" {
  provider = google-beta
  name     = var.name

  managed {
    domains = [var.domain]
  }
}
