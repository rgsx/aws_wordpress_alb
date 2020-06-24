resource "aws_launch_configuration" "lc-wordpress" {
  name_prefix     = "lc_wordpress"
  image_id        = aws_ami_from_instance.ami_wordpress.id
  instance_type   = "t2.micro"
  key_name        = "rgsx_key"
  security_groups = [aws_security_group.sg_inst_gr.id]
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
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 10
    port                = 80
    path                = "/wp-login.php"
    protocol            = "HTTP"
    interval            = 30
    matcher             = "200"
  }
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
