provider "aws" {
  region = "us-east-1"
}

variable "instance_names" {
  type    = list(string)
  default = ["frontend","mongodb","catalogue","redis","user","cart","mysql","shipping","rabbitmq","payment","dispatch"]

}

   resource "aws_spot_instance_request" "spot_instance" {
     count           = length(var.instance_names)
     ami             = "ami-03265a0778a880afb"  # Replace with your desired AMI ID
     instance_type   = "t3.micro"      # Replace with your desired instance type
     key_name        = "Devops_practice_n.vargina"
     security_groups = ["Devops_practice"]
     spot_type       = "persistent"

# Other instance configuration settings (e.g., key_name, security_groups, etc.) go here

     tags = {
       Name = var.instance_names[count.index]
     }
#currently this phase not working properly need to tune
     provisioner "local-exec" {
       command = <<EOT
      aws route53 change-resource-record-sets --hosted-zone-id Z05621022OUI0T8QXYBUU --change-batch '
      {
        "Changes": [
          {
            "Action": "CREATE",
            "ResourceRecordSet": {
              "Name": "${var.instance_names[count.index]}.agnyaata.online",
              "Type": "A",
              "TTL": 30,
              "ResourceRecords": [
                {
                  "Value": "${self.private_ip}"
                }
              ]
            }
          }
        ]
      }'
    EOT
     }
   }