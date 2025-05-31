# ====================================================
# リソースの情報をモジュール外部に出力
# ====================================================
output "samp_alb_certificate_arn" {
  value       = aws_acm_certificate_validation.samp_alb_cert_validation.certificate_arn  
}