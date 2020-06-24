provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "cicd-me-uk"
    workspaces {
      name = "aws_wordpress_alb"
    }
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

resource "aws_instance" "instance_wordpress" {
  ami                    = var.instance_ami_one
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  subnet_id              = aws_subnet.subnet_public_a.id
  vpc_security_group_ids = [aws_security_group.sg_inst.id]

  provisioner "remote-exec" {
      inline = [
       "echo 1"
      ]
      connection {
        type = "ssh"
        user = var.username
        private_key = file(var.ssh_key_path)
        host = self.public_ip
      }
  }

  provisioner "local-exec" {
    command = <<EOT
      rm -f hosts
      echo "[${var.host_label}:vars]" > hosts
      echo "ansible_ssh_user=${var.username}" >> hosts
      echo "ansible_ssh_private_key_file=${var.ssh_key_path}" >> hosts
      echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> hosts 
      echo "[${var.host_label}]" >> hosts
      echo ${self.public_ip} >> hosts
      ansible-playbook -i hosts -e efs_file_system_name=${aws_efs_file_system.efs-wordpress.dns_name} \
                                -e mysql_db=${var.dbname} \
                                -e mysql_user=${var.dbuser} \
                                -e mysql_password=${var.dbpassword} \
                                -e mysql_host=${aws_db_instance.db_wordpress.address} \
      provision.yml
   EOT
  }
  depends_on = [
    aws_efs_mount_target.efs-mount_pra,
    aws_db_instance.db_wordpress
  ]
}

resource "aws_ami_from_instance" "ami_wordpress" {
  name               = "ami_alb"
  source_instance_id = aws_instance.instance_wordpress.id
}
