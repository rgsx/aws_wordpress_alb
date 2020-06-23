/* resource "aws_launch_configuration" "lc-wordpress" {
  name_prefix     = "lc_wordpress"
  image_id        = var.instance_ami_gr
  instance_type   = "t2.micro"
  key_name        = "rgsx_key"
  security_groups = [aws_security_group.sg_inst_gr.id]
  user_data       = <<-EOF
  #!/bin/bash
  sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs-wordpress.dns_name}:/ /efs
 EOF
}
resource "aws_autoscaling_group" "as-wordpress" {
  name                      = "as-wordpress1"
  vpc_zone_identifier       = [aws_subnet.subnet_private_a.id, aws_subnet.subnet_private_b.id]
  launch_configuration      = aws_launch_configuration.lc-wordpress.name
  min_size                  = 1
  max_size                  = 3
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
    aws_efs_mount_target.efs-mount_prb,
    aws_instance.instance_wordpress,
    aws_db_instance.db_wordpress
  ]
}
resource "aws_alb" "alb-wordpress" {
  name            = "alb-wordpress"
  security_groups = [aws_security_group.sg_alb.id]
  subnets         = [aws_subnet.subnet_public_a.id, aws_subnet.subnet_public_b.id]
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
} */
