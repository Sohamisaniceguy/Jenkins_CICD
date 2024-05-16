output "alb_sg_id" {
  value = module.alb_sg.security_group_id
}

output "ec2_sg_id" {
  value = module.ec2_sg.security_group_id
}