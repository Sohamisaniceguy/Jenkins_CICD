module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "Tier2App-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = [module.alb_sg.security_group_id]
  enable_deletion_protection=false #This is True by default

  access_logs = {
    bucket = "Tier2App-alb-logs"
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
    #   redirect = {
    #     port        = "443"
    #     protocol    = "HTTPS"
    #     status_code = "HTTP_301"
    #   }
    }
    ex-https = {
    #   port            = 443
    #   protocol        = "HTTPS"
    #   certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name                              = "Tier2App-EC2-TG"
      protocol                          = "HTTP"
      port                              = 80
      target_type                       = "instance"
      vpc_id                            = module.vpc.vpc_id
      

      health_check = {
        enabled             = true
        interval            = 300
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 2
        unhealthy_threshold = 5
        timeout             = 60
        matcher             = "200"
      }

      protocol_version = "HTTP1"
      target_id        = aws_instance.this.id
      port             = 80
      tags = {
        InstanceTargetGroupTag = "EC2-clientTG"
      }
    }

#     resource "aws_lb_target_group" "alb_target_group" {
#   name        = "${var.project_name}-tg"
#   target_type = "instance"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = var.vpc_id

#   health_check {
#     enabled             = true
#     interval            = 300
#     path                = "/"
#     timeout             = 60
#     matcher             = 200
#     healthy_threshold   = 2
#     unhealthy_threshold = 5
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

  tags = {
    Name= "Tier2App-ALB"
    Environment = "dev"
    # Project     = "Example"
  }
}
}