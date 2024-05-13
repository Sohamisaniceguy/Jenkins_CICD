
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.Tier2App_distribution.domain_name
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.Tier2App_distribution.id
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.Tier2App_distribution.arn
}


output "cloudfront_status" {
  value = aws_cloudfront_distribution.Tier2App_distribution.status
}

output "cloudfront_hosted_zone_id" {
  value = aws_cloudfront_distribution.Tier2App_distribution.hosted_zone_id
}