resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet"
  subnet_ids = [aws_subnet.subnet_private_a.id, aws_subnet.subnet_private_b.id]

  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_db_instance" "db_wordpress" {
  identifier              = "db-wordpress"
  allocated_storage       = 20
  max_allocated_storage   = 30
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  vpc_security_group_ids  = [aws_security_group.sg_db.id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.name
  name                    = var.dbname
  username                = var.dbuser
  password                = var.dbpassword
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = "true"
  backup_retention_period = "0" //!!!! not null if you  want to have a replica-host
  tags = {
    "environment" = var.environment_tag
  }
}

/*
resource "aws_db_instance" "db_wordpress_replica" {
  identifier              = "db-wordpress-replica"
  allocated_storage       = 20
  max_allocated_storage   = 30
  storage_type            = "gp2"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  skip_final_snapshot     = "true"
  vpc_security_group_ids  = [aws_security_group.sg_db.id]
  replicate_source_db = aws_db_instance.db_wordpress.identifier
  tags = {
    "environment" = var.environment_tag
  }
} */
