variable "region" {
description = "The AWS region."
default = "us-east-1"
}
variable "key_name" {
description = "The AWS key pair to use for resources."
default = "ec2_key"
}

variable "ami" {
  type    = map(string)
  default = {
    "us-east-1" = "ami-04505e74c0741db8d"
    "us-west-2" = "image-4567"
  }
}
variable "instance_type" {
description = "The instance type."
default = "t2.micro"
}

variable "instance_ips" {
description = "The IPs to use for our instances"
default = ["10.0.1.20", "10.0.1.21" ]
}