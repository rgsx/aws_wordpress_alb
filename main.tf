provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}
resource "aws_vpc" "vpc" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = var.vpc_cidr
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_subnet" "subnet_public_a" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  cidr_block              = var.cidr_subnet_public_a
  availability_zone       = var.availability_zone_a
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_subnet" "subnet_private_a" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  cidr_block              = var.cidr_subnet_private_a
  availability_zone       = var.availability_zone_a
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_subnet" "subnet_public_b" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  cidr_block              = var.cidr_subnet_public_b
  availability_zone       = var.availability_zone_b
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_subnet" "subnet_private_b" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "false"
  cidr_block              = var.cidr_subnet_private_b
  availability_zone       = var.availability_zone_b
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_route_table" "rtbl" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.rtbl.id
}
resource "aws_route_table_association" "rtb" {
  subnet_id      = aws_subnet.subnet_public_b.id
  route_table_id = aws_route_table.rtbl.id
}
resource "aws_security_group" "sg_db" {
  name   = "sg_db"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_inst.id, aws_security_group.sg_inst_gr.id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_security_group" "sg_efs" {
  name   = "sg_efs"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_inst.id, aws_security_group.sg_inst_gr.id]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_security_group" "sg_inst" {
  name   = "sg_inst"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_security_group" "sg_inst_gr" {
  name   = "sg_inst_gr"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_inst.id]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.sg_alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_security_group" "sg_alb" {
  name   = "sg_alb"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_efs_file_system" "efs-wordpress" {
  creation_token   = "efs-wordpress"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = "false"
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_efs_mount_target" "efs-mount_pra" {
  file_system_id  = aws_efs_file_system.efs-wordpress.id
  subnet_id       = aws_subnet.subnet_private_a.id
  security_groups = [aws_security_group.sg_efs.id]
}
resource "aws_efs_mount_target" "efs-mount_prb" {
  file_system_id  = aws_efs_file_system.efs-wordpress.id
  subnet_id       = aws_subnet.subnet_private_b.id
  security_groups = [aws_security_group.sg_efs.id]
}
/* resource "aws_efs_mount_target" "efs-mount_puba" {
  file_system_id  = aws_efs_file_system.efs-wordpress.id
  subnet_id       = aws_subnet.subnet_public_a.id
  security_groups = [aws_security_group.sg_efs.id]
}
resource "aws_efs_mount_target" "efs-mount_pubb" {
  file_system_id  = aws_efs_file_system.efs-wordpress.id
  subnet_id       = aws_subnet.subnet_public_b.id
  security_groups = [aws_security_group.sg_efs.id]
} */
resource "aws_instance" "instance_wordpress" {
  ami                    = var.instance_ami_gr
  instance_type          = var.instance_type
  key_name               = var.aws_key_name
  subnet_id              = aws_subnet.subnet_public_a.id
  vpc_security_group_ids = [aws_security_group.sg_inst.id]

  provisioner "remote-exec" {
    inline = [<<EOT
      sudo apt-get -y -qq update &&  sudo apt-get -y -qq install nfs-common > /dev/null 
      sudo mkdir /efs-wordpress
      sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs-wordpress.dns_name}:/ /efs-wordpress
      sudo touch /efs-wordpress/a   
      EOT
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("rgsx_key.pem")
      host        = self.public_ip
    }
  }
  depends_on = [
    aws_efs_mount_target.efs-mount_pra,
  ]
}
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet"
  subnet_ids = [aws_subnet.subnet_private_a.id, aws_subnet.subnet_private_b.id]

  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_db_instance" "db_wordpress" {
  identifier             = "db-wordpress"
  allocated_storage      = 20
  max_allocated_storage  = 30
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_db.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  name                   = "wordpress"
  username               = "wordpress"
  password               = "wordpress"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = "true"
  tags = {
    "environment" = var.environment_tag
  }
}
resource "aws_launch_configuration" "lc-wordpress" {
  name_prefix     = "lc_wordpress"
  image_id        = var.instance_ami_gr
  instance_type   = "t2.micro"
  key_name        = "rgsx_key"
  security_groups = [aws_security_group.sg_inst_gr.id]
  user_data       = <<-EOF
    #!/bin/bash
    sudo umount -a
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs-wordpress.dns_name}:/ /efs-wordpress
  EOF
}
resource "aws_autoscaling_group" "as-wordpress" {
  name                      = "as-wordpress"
  vpc_zone_identifier       = [aws_subnet.subnet_private_a.id, aws_subnet.subnet_private_b.id]
  launch_configuration      = aws_launch_configuration.lc-wordpress.name
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  tag {
    key                 = "environment"
    value               = var.environment_tag
    propagate_at_launch = true
  }
  depends_on = [
    aws_efs_mount_target.efs-mount_pra,
    aws_efs_mount_target.efs-mount_prb
  ]
}
resource "aws_alb" "alb-wordpress" {
  name                = "alb-wordpress"
  security_groups     = [aws_security_group.sg_alb.id]
  subnets             = [aws_subnet.subnet_public_a.id, aws_subnet.subnet_public_b.id]
  tags = {
    Environment = var.environment_tag
  }
}
resource "aws_alb_target_group" "tg-alb" {
  name     = "tg-alb"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}
resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.alb-wordpress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.tg-alb.arn
    type             = "forward"
  }
}
resource "aws_autoscaling_attachment" "attach-atg-albtg" {
  autoscaling_group_name = aws_autoscaling_group.as-wordpress.id
  alb_target_group_arn   = aws_alb_target_group.tg-alb.arn
}
