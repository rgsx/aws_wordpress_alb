variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "username" {
  type    = string
  default = "ec2-user"
}
variable "ssh_key_name" {
  type    = string
  default = "rgsx_key"
}

variable "host_label" {
  type    = string
  default = "instance"
}

variable "ssh_key_path" {
  type    = string
  default = "rgsx_key.pem"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "availability_zone_a" {
  type    = string
  default = "eu-central-1a"
}

variable "availability_zone_b" {
  type    = string
  default = "eu-central-1b"
}

#ubuntu 18.04
variable "instance_ami_one" {
  type    = string
  default = "ami-0a02ee601d742e89f"
}

variable "instance_ami_gr" {
  type    = string
  default = "ami-0efb4be38cce7c374"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cidr_subnet_public_a" {
  type    = string
  default = "10.0.1.0/24"
}

variable "cidr_subnet_public_b" {
  type    = string
  default = "10.0.2.0/24"
}

variable "cidr_subnet_private_a" {
  type    = string
  default = "10.0.10.0/24"
}

variable "cidr_subnet_private_b" {
  type    = string
  default = "10.0.20.0/24"
}

variable "environment_tag" {
  type    = string
  default = "wordpress"
}

variable "dbname" {
  type = string
}

variable "dbuser" {
  type = string
}

variable "dbpassword" {
  type = string
}

variable "default_tags" {
 description = "The set of tags."
 type = map
 default = {
             "Environment" = "dev",
             "Project" = "wordpress",
           }
}

variable "acm-certificate-arn" {
  type = string
  default = "arn:aws:acm:us-east-1:361838629300:certificate/a6b9b701-add8-4ca4-a752-b2254fa2a285"
}