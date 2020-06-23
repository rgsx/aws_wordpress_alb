resource "aws_instance" "instance_wordpress" {
  ami                    = var.instance_ami_one
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  subnet_id              = aws_subnet.subnet_public_a.id
  vpc_security_group_ids = [aws_security_group.sg_inst.id]

 /*  provisioner "remote-exec" {
      inline = [
       "hostnamectl set-hostname wordpress_worker"
      ]
      connection {
        type = "ssh"
        user = var.username
        private_key = file(var.ssh_key_path)
        host = self.public_ip
      }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' --private-key ${var.ssh_key_path} provision.yml"
  } */
}

  /* provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y  update && sudo apt-get -y  install nfs-common",
      "sudo mkdir /efs",
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.efs-wordpress.dns_name}:/ /efs",
      "if [ ! -d /efs/wp-admin ] ; then wget https://wordpress.org/latest.tar.gz; sudo tar -zxvf latest.tar.gz --strip-components 1  -C /efs; sudo chown -R www-data:www-data /efs; sudo chmod a+rw /efs; rm latest.tar.gz; fi",
       ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("rgsx_key.pem")
      host        = self.public_ip
    }
  }
  provisioner "file" {
    content =  templatefile("wp-config.php.tpl", {
      db_name = var.dbname,
      db_user = var.dbuser,
      db_password = var.dbpassword
      db_host = aws_db_instance.db_wordpress.address
     }
    )
    destination = "/efs/wp-config.php"
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
}*/

