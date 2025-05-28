# ====================================================
# リソースの情報をモジュール外部に出力
# ====================================================
output "target_group_1_arn" {
  value = aws_lb_target_group.samp_web_tg_1.arn
}

output "samp_lb_dns_name" {
  value = aws_lb.samp_web.dns_name  
}

output "samp_lb_zone_id" {
  value = aws_lb.samp_web.zone_id
}