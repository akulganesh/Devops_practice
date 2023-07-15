provider "aws" {
  region = "us-east-1"
}
variable "instance_hostnames" {
  type    = list(string)
  default = ["frontend","mongodb","catalogue","redis","user","cart","mysql","shipping","rabbitmq","payment","dispatch"]

}
resource "aws_instance" "ec2_instance" {
  count         = 11
  ami           = "ami-03265a0778a880afb"  # Replace with your desired AMI ID
  instance_type = "t3.micro"      # Replace with your desired instance type
  key_name        = "Devops_practice_n.vargina"
  security_groups = ["Devops_practice"]

  # Other instance configuration settings go here

  tags = {
    name = "${element(var.instance_hostnames,count.index)}"
  }
}

resource "aws_route53_zone" "dns_zone" {
name = "agnyaata.online"  # Replace with your desired DNS zone name
}

resource "aws_route53_record" "dns_record" {
  count    = length(var.instance_hostnames)
  zone_id  = aws_route53_zone.dns_zone.zone_id
  name     = "${var.instance_hostnames[count.index]}.agnyaata.online"
  type     = "A"
  ttl      = 30
  records  = [aws_instance.ec2_instance[count.index].public_ip]
}