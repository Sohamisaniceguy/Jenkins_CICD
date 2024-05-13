output "target_group_arn" {
  value = aws_lb_target_group.Tier2App-alb-tg.arn
}

output "alb_dns_name" {
  value = aws_lb.Tier2App-alb.dns_name
}