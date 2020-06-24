resource "aws_launch_configuration" "lc-wordpress" {
  name_prefix     = "lc_wordpress"
  image_id        = aws_ami_from_instance.ami_wordpress.id
  instance_type   = "t2.micro"
  key_name        = "rgsx_key"
  security_groups = [aws_security_group.sg_inst_gr.id]
}

resource "aws_autoscaling_group" "as-wordpress" {
  name                      = "as-wordpress"
  vpc_zone_identifier       = [aws_subnet.subnet_private_a.id, aws_subnet.subnet_private_b.id]
  launch_configuration      = aws_launch_configuration.lc-wordpress.name
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 300
  health_check_type         = "ELB"
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
resource "aws_autoscaling_policy" "cpu-policy-scaleup" {
  name                   = "cpu-policy-scaleup"
  autoscaling_group_name = aws_autoscaling_group.as-wordpress.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}
resource "aws_autoscaling_policy" "cpu-policy-scaledown" {
  name                   = "cpu-policy-scaledown"
  autoscaling_group_name = aws_autoscaling_group.as-wordpress.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}
resource "aws_cloudwatch_metric_alarm" "cpu-alarm" {
  alarm_name          = "cpu-alarm"
  alarm_description   = "cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.as-wordpress.name 
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.cpu-policy-scaleup.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaledown" {
  alarm_name          = "cpu-alarm-scaledown"
  alarm_description   = "cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5"
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.as-wordpress.name
  }
  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.cpu-policy-scaledown.arn]
}
