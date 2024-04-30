#Key Pair passing:
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "Tier2app-Ec2Key"
  public_key = file("key1.pem")
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "2Tier-asg"

  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = slice(module.vpc.private_subnets,0,2)
  


  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
      max_healthy_percentage = 100
    }
    triggers = ["tag"]
  }

  # Launch template
  launch_template_name        = var.instance_name
  launch_template_description = "Launch template for ASG"
  image_id          = var.image_id
  instance_type     = var.instance_type
  key_name          = module.key_pair.key_name
  ebs_optimized     = true
  enable_monitoring = true
  user_data = base64encode(file("config_ec2.sh"))
  
  
  tags = {
    Name = "EC2-ASG"
    Environment = "dev"
  }
}