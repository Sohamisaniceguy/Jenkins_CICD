# module "alb" {
#   source = "terraform-aws-modules/alb/aws"

#   name    = "Tier2App-alb"
#   vpc_id  = module.vpc.vpc_id
#   subnets = module.vpc.public_subnets

#   security_groups = [module.alb_sg.security_group_id]
#   enable_deletion_protection=false #This is True by default

# #   access_logs = {
# #     bucket = "Tier2App-alb-logs"
# #   }

# tags = {
#   Name = "Tier2App-ALB"
# }

# }

# #Listner:
# resource "aws_lb_listener" "alb_http_listner" {
#   load_balancer_arn = module.alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.alb_target_group.arn
#   }
# }
