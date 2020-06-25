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
  tags = var.default_tags
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
  tags = var.default_tags
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
  tags = var.default_tags
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
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.default_tags
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
  tags = var.default_tags
}