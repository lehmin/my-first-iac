# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = var.aws_profile
}

# Create VPC
resource "aws_vpc" "MyVPC" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "MyVPC"
  }
}

# Creates Internet Gateway 

resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.MyVPC.id

  tags = {
    Name = "MyIGW"
  }
}


# Creates a public Route Table
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.MyVPC.id

  route {
    cidr_block = var.PublicRT_cidr
    gateway_id = aws_internet_gateway.MyIGW.id
  }

  tags = {
    Name = "MyPublicRT"
  }
}

# Creates public subnet
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "PublicSubnet"
  }
}

# Public Subnet's route table association
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.PublicRT.id 
}

# Creates a SG for webserver
resource "aws_security_group" "webSG" {
  name        = "allow_tls"
  description = "Allows web traffic and ssh"
  vpc_id      = aws_vpc.MyVPC.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_webtraffic"
  }
}

resource "aws_network_interface" "Webserver-nic" {
  subnet_id   = aws_subnet.subnet1.id
  private_ips = ["10.1.1.50"]
  security_groups = [aws_security_group.webSG.id]
}

#Creates an elastic IP 

resource "aws_eip" "eip1" {
  vpc = true
  network_interface  = aws_network_interface.Webserver-nic.id
  associate_with_private_ip = "10.1.1.50"
  depends_on = [aws_internet_gateway.MyIGW]
}

# Creates a worpress instance
resource "aws_instance" "wordpress" {
  ami = "ami-0c197d3fbe9b53216" # wordpress 
  instance_type = "t2.micro"
  key_name = "my_keys"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         
  availability_zone = "us-east-1a"

  network_interface {
    network_interface_id = aws_network_interface.Webserver-nic.id
    device_index   = 0
  }

  tags = {
      Name = "wordpress"
  }
}

resource "aws_eip_association" "wp_eip_assoc" {
  instance_id   = aws_instance.wordpress.id
  allocation_id = aws_eip.eip1.id
}

resource "aws_key_pair" "my_keys" {
    key_name  = "my_keys"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYs5I4Y9Ru914hdeiBWGejAoaIyreCVzvPGXR9shXBp81ZyDIgFYxDmoUIDbyRVY0S4gR0mlqgpFHBiRCBP0lqy3kJ1XRRPSy+GN4ksCxrMpBcW/NqA1osxzVAbE7/0sKNkBO2xVzr3gM4XRXouWu17oahaZHU5rcclKSnjuwJ/48Xws1leQ/Yj2ilDFiw9UG7/lWqxmIVtwXNdUvZRxn7hdFpAAHW32HCW1uBS5djfJxSgGqXAx14K5/8cFGYTrZYcfWrJWHExTM7+SWSVIN3J9OhIxYa7eI3DslNW2cSMj4SA5Ezvq72gqO3hDBMYKpL6uSPJ7rhilp8JxCWf2p6mCmi1c57dkwoK3UEGExdfFetBDI57EiX1dq9l/S6Hrs2vXIkyJluUlHGHblktHkz4ga0hcJXay2gRcZCFIXF0ZpBjOo5FVGPmC8As1FVMdoCMTwhkDhd2fqD4ygo/Yu3iO14Cxka7EnmSb84s2HAlYcFZykgrFj34VWTX3FMt7OWHseA0irGeIa1fSCoWaGR33aZdMNhqTagDh9xd61icl/mwiNP5sKbxz8ZplN1/Z/mEQcjcBIn7UGdKZINuL3s49qM7ZdAYN5CPu0Xbne88Crq3eKoeIaGwbMTCioCc+75LTRbNUITlXPYb+jBf963xpuCbAzZDCDPRJflNqBXzw== abbey@SP.local"
}
