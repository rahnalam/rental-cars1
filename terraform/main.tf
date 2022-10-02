locals {
	  vpc_id           = "vpc-09f6df513c48fdef7"
	  subnet_id        = "subnet-06733639e38978678"
	  ssh_user         = "ubuntu"
	  key_name         = "project"
	}


	provider "aws" {
	  region = "us-west-1"
	}


	resource "aws_security_group" "test" {
	  name   = "test_access"
	  vpc_id = local.vpc_id


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
	}


	resource "aws_instance" "tomcat" {
	  ami                         = "ami-085284d24fe829cd0"
	  subnet_id                   = "subnet-06733639e38978678"
	  instance_type               = "t2.micro"
	  associate_public_ip_address = true
	  security_groups             = [aws_security_group.test.id]
	  key_name                    = local.key_name
	}


	output "tomcat_ip" {
	  value = aws_instance.tomcat.public_ip
	}
