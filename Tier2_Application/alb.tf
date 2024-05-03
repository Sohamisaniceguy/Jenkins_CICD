module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "Tier2App-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = [module.alb_sg.security_group_id]
  enable_deletion_protection=false #This is True by default

#   access_logs = {
#     bucket = "Tier2App-alb-logs"
#   }

listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }

      rules = {
        ex-fixed-response = {
          priority = 3
          actions = [{
            type         = "fixed-response"
            content_type = "text/plain"
            status_code  = 200
            message_body = "This is a fixed response"
          }]

          conditions = [{
            http_header = {
              http_header_name = "x-Gimme-Fixed-Response"
              values           = ["yes", "please", "right now"]
            }
          }]
        }


#   target_groups = {
#     ex-instance = {
#       name                              = "Tier2App-EC2-TG"
#       protocol                          = "HTTP"
#       port                              = 80
#       target_type                       = "instance"
#       vpc_id                            = module.vpc.vpc_id
      

#       health_check = {
#         enabled             = true
#         interval            = 300
#         path                = "/healthz"
#         port                = "traffic-port"
#         healthy_threshold   = 2
#         unhealthy_threshold = 5
#         timeout             = 60
#         matcher             = "200"
#       }

#       protocol_version = "HTTP1"
#       target_id        = aws_instance.this.id # Problem
#       port             = 80
#       tags = {
#         InstanceTargetGroupTag = "EC2-clientTG"
#       }
#     }


#   tags = {
#     Name= "Tier2App-ALB"
#     Environment = "dev"
#     # Project     = "Example"
#   }
# }



target_groups = [
    {
      backend_protocol        = "HTTP"
      backend_port            = 80
      target_type             = "instance"
      health_check_path       = "/"
      health_check_port       = "80"
      health_check_protocol   = "HTTP"
      health_check_timeout    = 5
      health_check_interval   = 30
      healthy_threshold       = 2
      unhealthy_threshold     = 2
      matcher                 = "200"
      name                    = "my-target-group"
      deregistration_delay    = 300
    #   stickiness_cookie_duration = 3600
    #   stickiness_type         = "lb_cookie"
    }
  ]

  


}

    }

}
}