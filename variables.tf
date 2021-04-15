variable "aws_profile" {}

variable "ami" {
    description = "AMIs by region"
    default = {
        us-east-1 = "ami-00e87074e52e6c9f9" # centos 7
    }
}
variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.1.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.1.1.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.1.2.0/24"
}

variable "PublicRT_cidr" {
    description = "CIDR for the Route Table"
    default = "0.0.0.0/0"
}
