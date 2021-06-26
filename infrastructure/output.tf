output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = aws_acm_certificate.compoze_acm.arn
}
output "api_dns_name" {
  description = "The DNS Url for API"
  value       = local.dns_name
}