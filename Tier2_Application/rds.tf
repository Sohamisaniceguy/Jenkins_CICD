# resource "aws_db_subnet_group" "Tier2App-db-subnet" {
#   name = "db_subnet"
#   subnet_ids = slice(module.vpc.private_subnets,2,4)
# }

# resource "aws_db_instance" "Tier2App-RDS" {

#   identifier              = "bookdb-instance"
#   allocated_storage    = 20
#   db_name              = "Tier2App-RDS"
#   engine               = "mysql"
#   engine_version       = "8.0.35"
#   instance_class       = "db.t2.micro"
#   username             = "foo"
#   password             = "foobarbaz"
# #   parameter_group_name = "default.mysql8.0"
#   multi_az                = true
#   storage_type            = "gp2"
#   storage_encrypted       = false
#   publicly_accessible     = false
#   skip_final_snapshot     = true
#   backup_retention_period = 0

#   vpc_security_group_ids = [module.db_sg.security_group_id]
#   db_subnet_group_name = aws_db_subnet_group.Tier2App-db-subnet.name
# }

# # Problem is with costing 
# Check about the connection between EC2 & RDS