
data "aws_route53_zone" "public-zone" {
  name         = "cloudcraftsmanlab.com"
  private_zone = false
}
resource "aws_route53_record" "cloudfront_record" {
  zone_id = data.aws_route53_zone.public-zone.zone_id
  name    = "Tier2-App-Route53"
  type    = "A"

  alias {
    name                   = aws_lb.Tier2App-alb.dns_name
    zone_id                = aws_lb.Tier2App-alb.zone_id
    evaluate_target_health = false
  }
}