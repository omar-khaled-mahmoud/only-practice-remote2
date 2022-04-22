region = "us-east-1"
ami = {
us-east-1 = "ami-03ededff12e34e59e"
us-west-1 = "ami-7c4b331c"
}
key_name = "ec2_key"

variable "instance_ips" {
description = "The IPs to use for our instances"
default = ["10.0.1.20", "10.0.1.21" ]
}