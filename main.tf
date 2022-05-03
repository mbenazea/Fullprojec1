


#create vpc
resource "aws_vpc" "webserver-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name  = "myweb-vpc"
    env   = "dev"
    owner = "Marcelus"
  }

}

#create igw
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.webserver-vpc.id
  tags = {
    Name = "my-igw"
  }
}

#create a custom route table
resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.webserver-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
    Name = "Public-RT"
  }
}


#create subnet
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.webserver-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

#associate subnet with RT
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.Public-RT.id
}

#create SG to allow port 22, 80, 443
resource "aws_security_group" "webserver-SG" {
  vpc_id      = aws_vpc.webserver-vpc.id
  name        = "webserver-SG"
  description = "Allow SSH access to developers"
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #defining outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "webserver-SG"
    owner = "Marcelus"
  }
}
#Create a network interface with an IP in the subnet that was created in step 4
resource "aws_network_interface" "my-Network-Interface" {
  subnet_id       = aws_subnet.public-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.webserver-SG.id]

}

#8-Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "my-elastic-ip" {
  vpc                       = true
  network_interface         = aws_network_interface.my-Network-Interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.my-igw]

}

#9-Create an ubuntu server and install/enable apache 2
resource "aws_instance" "ubuntu-server" {
  instance_type     = var.instance_type
  ami               = var.region
  availability_zone = "us-east-1a"
  key_name          = "mykeypair"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.my-Network-Interface.id
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo systemctl enable apache2
    echo "<h1>WE DID IT!</h1>" | sudo tee /var/www/html/index.html
    EOF

}




