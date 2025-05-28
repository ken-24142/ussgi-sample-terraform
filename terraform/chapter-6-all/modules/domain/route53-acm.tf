# ====================================================
# Route53 Record、ACM
# ====================================================
# Route53 (マネコンで作成したドメインを取り込む)
data "aws_route53_zone" "samp_domain" {
  name         = var.samp_domain_name
  private_zone = false
}

# ACM
resource "aws_acm_certificate" "samp_alb" {
  domain_name               = data.aws_route53_zone.samp_domain.name
  subject_alternative_names = [format("*.%s", data.aws_route53_zone.samp_domain.name)]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

## ACM validation
resource "aws_route53_record" "samp_alb_validation" {
  for_each = {
    for dvo in aws_acm_certificate.samp_alb.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = data.aws_route53_zone.samp_domain.id
  name            = each.value.name
  type            = each.value.type
  ttl             = 300
  records         = [each.value.record]
  allow_overwrite = true
}

## Alias record
resource "aws_route53_record" "samp_alb_alias" {
  zone_id = data.aws_route53_zone.samp_domain.id
  name    = data.aws_route53_zone.samp_domain.name
  type    = "A"

  alias {
    name                   = "dualstack.${var.samp_lb_dns_name}"
    zone_id                = var.samp_lb_zone_id
    evaluate_target_health = true
  }
}
