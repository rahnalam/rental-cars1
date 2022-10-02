output "ec2instance_ip" {
  value = "${aws_instance.tomcat.public_ip}"
}