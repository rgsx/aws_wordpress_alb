/* data "aws_route53_zone" "selected" {
  name         = "cicd.me.uk."
  private_zone = false
}

resource "aws_route53_record" "cname_wordpress" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_alb.alb-wordpress.dns_name]
}

resource "aws_route53_record" "alias_wordpress" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "cicd.me.uk"
  type    = "A"
  alias {
    name                   = aws_alb.alb-wordpress.dns_name
    zone_id                = aws_alb.alb-wordpress.zone_id
    evaluate_target_health = true
  }
}
 */
