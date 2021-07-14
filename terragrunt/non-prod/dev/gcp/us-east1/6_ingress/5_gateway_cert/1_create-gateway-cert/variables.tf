variable "create" {
  description = "Create Module, defaults to true."
  default     = true
}

variable "name" {
  description = "Filename to write the certificate data to, default to \"tls-self-signed-cert\"."
  default     = "tls-self-signed-cert"
}

variable "algorithm" {
  description = "The name of the algorithm to use for the key. Currently-supported values are \"RSA\" and \"ECDSA\". Defaults to \"RSA\"."
  default     = "RSA"
}

variable "rsa_bits" {
  description = "When algorithm is \"RSA\", the size of the generated RSA key in bits. Defaults to \"2048\"."
  default     = "2048"
}

variable "ecdsa_curve" {
  description = "When algorithm is \"ECDSA\", the name of the elliptic curve to use. May be any one of \"P224\", \"P256\", \"P384\" or \"P521\". Defaults to \"P224\""
  default     = "P256"
}

variable "permissions" {
  description = "The Unix file permission to assign to the cert files (e.g. 0600). Defaults to \"0600\"."
  default     = "0600"
}

variable "validity_period_hours" {
  description = "The number of hours after initial issuing that the certificate will become invalid."
}

variable "ca_allowed_uses" {
  description = "List of keywords from RFC5280 describing a use that is permitted for the CA certificate. For more info and the list of keywords, see https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#allowed_uses."
  type        = list(string)

  default = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
}

variable "ca_common_name" {
  description = "The common name to use in the subject of the CA certificate (e.g. hashicorp.com)."
  default     = ""
}

variable "organization_name" {
  description = "The name of the organization to associate with the certificates (e.g. HashiCorp Inc)."
}

variable "allowed_uses" {
  description = "List of keywords from RFC5280 describing a use that is permitted for the issued certificate. For more info and the list of keywords, see https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html#allowed_uses."
  type        = list(string)

  default = [
    "key_encipherment",
    "digital_signature",
  ]
}

variable "common_name" {
  description = "The common name to use in the subject of the certificate (e.g. hashicorp.com)."
}

variable "dns_names" {
  description = "List of DNS names for which the certificate will be valid (e.g. foo.hashicorp.com), defaults to empty list."
  type        = list(string)
  default     = []
}

variable "ip_addresses" {
  description = "List of IP addresses for which the certificate will be valid (e.g. 127.0.0.1), defaults to empty list."
  type        = list(string)
  default     = []
}

variable "ca_override" {
  description = "Don't create a CA cert, override with the provided CA to sign certs with."
  default     = false
}

variable "ca_key_override" {
  description = "CA private key pem override."
  default     = ""
}

variable "ca_cert_override" {
  description = "CA cert pem override."
  default     = ""
}

variable "download_certs" {
  description = "Download certs locally, defaults to false."
  default     = false
}

variable "cert_output_dir" {
  description = "Path where to save the certs"
  default = "." 
}

