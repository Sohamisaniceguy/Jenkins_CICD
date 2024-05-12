# # # # Initializzing 2 EC2 Instances:
# # # module "ec2_instance" {
# # #   source  = "terraform-aws-modules/ec2-instance/aws"

# # #   name = "single-instance"

# # #   instance_type          = "t2.micro"
# # # #   key_name               = module.key_pair.key_pair_name
# # #   monitoring             = true
# # #   vpc_security_group_ids = [module.ec2_sg.security_group_id]
# # #   subnet_id              = module.vpc.private_subnets[0]

# # #   tags = {
# # #     Name="Test"
# # #   }
# # # }

# # # #Key Pair passing:
# # # module "key_pair" {
# # #   source = "terraform-aws-modules/key-pair/aws"

# # #   key_name = "ASG-Key"
# # #   public_key = file("key1.pem")
# # # }

#Launch Templates:
resource "aws_launch_template" "Tier2App-EC2template" {
  name = "Tier2App-EC2template"
  image_id = var.image_id
  instance_type = "t2.micro"

  # key_name = "test"
  vpc_security_group_ids = [module.ec2_sg.security_group_id]
  user_data = base64encode(file("config_ec2.sh"))
  
  tags = {
    Name = "EC2-ASG"
    Environment = "dev"
  }
}

#Autoscaling Configuration:
resource "aws_autoscaling_group" "Tier2App-ASG" {
  name = "Tier2App-ASG"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "ELB"
  vpc_zone_identifier       = slice(module.vpc.private_subnets,0,2)
  target_group_arns = [aws_lb_target_group.Tier2App-alb-tg.arn]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id = aws_launch_template.Tier2App-EC2template.id
    version = aws_launch_template.Tier2App-EC2template.latest_version
  }
}


#Scaling up policy:
resource "aws_autoscaling_policy" "Tier2App-scale_up" {
  name                   = "Tier2App-scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.Tier2App-ASG.name
  policy_type            = "SimpleScaling"
}


#Scaling down policy:
resource "aws_autoscaling_policy" "Tier2App-scale_down" {
  name                   = "Tier2App-scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.Tier2App-ASG.name
  policy_type            = "SimpleScaling"
}


# Scaling up alarm:
resource "aws_cloudwatch_metric_alarm" "Tier2App-Up-alarm" {
  alarm_name          = "Tier2App-Up-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70 # New instance - when CPU utilization is > 30 %

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.Tier2App-ASG.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.Tier2App-scale_up.arn]
}

# Scaling down alarm:
resource "aws_cloudwatch_metric_alarm" "Tier2App-Down-alarm" {
  alarm_name          = "Tier2App-Down-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 5 # New instance - when CPU utilization is > 30 %

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.Tier2App-ASG.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.Tier2App-scale_down.arn]
}


