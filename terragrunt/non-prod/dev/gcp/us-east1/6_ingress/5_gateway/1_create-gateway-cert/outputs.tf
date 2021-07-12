output "zREADME" {
  value = <<-README
  # ------------------------------------------------------------------------------
  # ${var.name} TLS Self Signed Certs
  # ------------------------------------------------------------------------------

  The below private keys and self signed TLS certificates have been generated.

  - CA certificate: ${length(random_id.name.*.hex) > 0 ? format("%s-ca", random_id.name.*.hex[0]) : ""}
  - Leaf certificate: ${length(random_id.name.*.hex) > 0 ? format("%s-leaf", random_id.name.*.hex[0]) : ""}

  %{if var.download_certs~}
  The below certificates and private key have been downloaded locally with the
  file permissions updated appropriately.

  - ${length(random_id.name.*.hex) > 0 ? format("%s-ca.crt.pem", random_id.name.*.hex[0]) : ""}
  - ${length(random_id.name.*.hex) > 0 ? format("%s-leaf.crt.pem", random_id.name.*.hex[0]) : ""}
  - ${length(random_id.name.*.hex) > 0 ? format("%s-leaf.key.pem", random_id.name.*.hex[0]) : ""}

    # View your certs
    $ openssl x509 -text -in ${length(random_id.name.*.hex) > 0 ? format("%s-ca.crt.pem", random_id.name.*.hex[0]) : ""}
    $ openssl x509 -text -in ${length(random_id.name.*.hex) > 0 ? format("%s-leaf.crt.pem", random_id.name.*.hex[0]) : ""}

    # Verify root CA
    $ openssl verify -CAfile ${length(random_id.name.*.hex) > 0 ? format("%s-ca.crt.pem", random_id.name.*.hex[0]) : ""} \
      ${length(random_id.name.*.hex) > 0 ? format("%s-leaf.crt.pem", random_id.name.*.hex[0]) : ""}
  %{else~}
  Certs were not downloaded locally. set "download_certs" to true to download.
  %{endif~}
  README

}

output "algorithm" {
  value = var.algorithm
}

# CA - TLS private key
output "ca_private_key_pem" {
  value = length(tls_private_key.ca.*.private_key_pem) > 0 ? tls_private_key.ca.*.private_key_pem[0] : ""
}
output "ca_public_key_pem" {
  value = length(tls_private_key.ca.*.public_key_pem) > 0 ? tls_private_key.ca.*.public_key_pem[0] : ""
}
output "ca_public_key_openssh" {
  value = length(tls_private_key.ca.*.public_key_openssh) > 0 ? tls_private_key.ca.*.public_key_openssh[0] : ""

}

# CA - TLS self signed cert
output "ca_cert_name" {
  value = length(random_id.name.*.hex) > 0 ? formatlist("%s-ca", random_id.name.*.hex)[0] : ""
}

output "ca_cert_filename" {
  value = length(random_id.name.*.hex) > 0 ? format("%s-ca.crt.pem", random_id.name.*.hex[0]) : ""
}

output "ca_cert_pem" {
  value = length(tls_self_signed_cert.ca.*.cert_pem) > 0 ? tls_self_signed_cert.ca.*.cert_pem[0] : ""
}

output "ca_cert_validity_start_time" {
  value = length(tls_self_signed_cert.ca.*.validity_start_time) > 0 ? tls_self_signed_cert.ca.*.validity_start_time[0] : ""
}

output "ca_cert_validity_end_time" {
  value = length(tls_self_signed_cert.ca.*.validity_end_time) > 0 ? tls_self_signed_cert.ca.*.validity_end_time[0] : ""
}

# Leaf - TLS private key
output "leaf_private_key_pem" {
  value = length(tls_private_key.leaf.*.private_key_pem) > 0 ? tls_private_key.leaf.*.private_key_pem[0] : ""
}

output "leaf_private_key_filename" {
  value = length(random_id.name.*.hex) > 0 ? format("%s-leaf.key.pem", random_id.name.*.hex[0]) : ""
}

output "leaf_public_key_pem" {
  value = length(tls_private_key.leaf.*.public_key_pem) > 0 ? tls_private_key.leaf.*.public_key_pem[0] : ""
}

output "leaf_public_key_openssh" {
  value = length(tls_private_key.leaf.*.public_key_openssh) > 0 ? tls_private_key.leaf.*.public_key_openssh[0] : ""
}

output "leaf_cert_request_pem" {
  value = length(tls_cert_request.leaf.*.cert_request_pem) > 0 ? tls_cert_request.leaf.*.cert_request_pem[0] : ""
}

# Leaf - TLS locally signed cert
output "leaf_cert_name" {
  value = length(random_id.name.*.hex) > 0 ? format("%s-leaf", random_id.name.*.hex[0]) : ""
}

output "leaf_cert_filename" {
  value = length(random_id.name.*.hex) > 0 ? format("%s-leaf.crt.pem", random_id.name.*.hex[0]) : ""
}

output "leaf_cert_pem" {
  value = length(tls_locally_signed_cert.leaf.*.cert_pem) > 0 ? tls_locally_signed_cert.leaf.*.cert_pem[0] : ""
}

output "leaf_cert_validity_start_time" {
  value = length(tls_locally_signed_cert.leaf.*.validity_start_time) > 0 ? tls_locally_signed_cert.leaf.*.validity_start_time[0] : ""
}

output "leaf_cert_validity_end_time" {
  value = length(tls_locally_signed_cert.leaf.*.validity_end_time) > 0 ? tls_locally_signed_cert.leaf.*.validity_end_time[0] : ""
}
