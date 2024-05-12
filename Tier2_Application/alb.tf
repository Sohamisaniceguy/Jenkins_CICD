resource "aws_lb" "Tier2App-alb" {
  name               = "Tier2App-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.alb_sg.security_group_id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "Tier2App-alb-tg" {
  name     = "Tier2App-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "instance"

  health_check {
      enabled             = true
      interval            = 300
      path                = "/"
      timeout             = 60
      matcher             = "200"
      healthy_threshold   = 2
      unhealthy_threshold = 5
  }

  lifecycle {
    create_before_destroy = true
  }

}



resource "aws_lb_listener" "Tier2App-alb-lis" {
  load_balancer_arn = aws_lb.Tier2App-alb.arn
  port              = "80"
  protocol          = "HTTP"
  

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Tier2App-alb-tg.arn
  }
}



# module "alb" {
#   source = "terraform-aws-modules/alb/aws"

#   name    = "Tier2App-alb"
#   vpc_id  = module.vpc.vpc_id
#   subnets = module.vpc.public_subnets

#   security_groups = [module.alb_sg.security_group_id]
#   enable_deletion_protection=false #This is True by default

#   # access_logs = {
#   #   bucket = "Tier2App-alb-logs"
#   # }

# listeners = {
#     example_listener = {
#       port     = 80
#       protocol = "HTTP"
#       weighted_forward = {
#         target_groups = [
#           {
#             target_group_key = "ex-instance"
#             # weight           = 1
#           }
#         ]
#       }
#     }


# }

# target_groups = {
#     ex-instance = {
#       name_prefix      = "h1"
#       protocol         = "HTTP"
#       port             = 80
#       target_type      = "instance"

#     health_check = {
#       enabled             = true
#       interval            = 300
#       path                = "/"
#       timeout             = 60
#       matcher             = "200"
#       healthy_threshold   = 2
#       unhealthy_threshold = 5
#   }

#       protocol_version = "HTTP1"
#       target_id        = module.asg.autoscaling_group_id
#       port             = 80
#   }
# #  lifecycle = {
# #     create_before_destroy = true
# #   }
# }

# tags = {
#   Name = "Tier2App-ALB"
# }

# }

# output "alb_target_group_arn" {
#   value = module.alb.target_group_arn
# }


# # # create application load balancer
# # resource "aws_lb" "application_load_balancer" {
  
# #   internal           = false
# #   load_balancer_type = "application"
  
# #   name    = "Tier2App-alb"
# #   vpc_id  = module.vpc.vpc_id
# #   subnets = module.vpc.public_subnets

# #   security_groups = [module.alb_sg.security_group_id]
# #   enable_deletion_protection=false #This is True by default
# #   tags   = {
# #     Name = "Tier2App-ALB"
# #   }
# # }

# # #Listner:
# # resource "aws_lb_listener" "alb_http_listner" {
# #   load_balancer_arn = module.alb.arn
# #   port              = 80
# #   protocol          = "HTTP"

# #   default_action {
# #     type = "forward"
# #     target_group_arn = aws_lb_target_group.alb_target_group.arn
# #   }
# # }

# # #Target Group:
# # resource "alb_lb_target_group" "alb_target_group" {
# #   name= "Tier2App-alb-tg"
# #   port        = 80
# #   protocol    = "HTTP"
# #   target_type = "instance"
# #   vpc_id      = module.vpc.vpc_id

# #   health_check {
# #     enabled             = true
# #     interval            = 300
# #     path                = "/"
# #     timeout             = 60
# #     matcher             = 200
# #     healthy_threshold   = 2
# #     unhealthy_threshold = 5
# #   }

# #   lifecycle {
# #     create_before_destroy = true
# #   }

# # }

