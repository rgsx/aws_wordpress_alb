 data "aws_route53_zone" "selected" {
  name         = "cicd.me.uk."
  private_zone = false
}
resource "aws_route53_record" "cname_wordpress" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_cloudfront_distribution.distribution_wordpress.domain_name]
}
resource "aws_route53_record" "alias_wordpress" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "cicd.me.uk"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.distribution_wordpress.domain_name
    zone_id                = aws_cloudfront_distribution.distribution_wordpress.hosted_zone_id 
    evaluate_target_health = false
  }
}
 
