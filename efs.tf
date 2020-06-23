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