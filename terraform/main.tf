provider "aws" {
  region = "eu-west-2"
}

#variables 
# variable "db_ip" {
#   private_ip = "11.1.2.69"
# }

# resource "aws_eip" "db_ip" {
#   instance = "${aws_instance.db-kane.id}"
#   vpc      = true
# }

data "aws_ami" "kaneweb" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "name"
    values = ["kane-web-prod*"]
  }

  most_recent = true
}

#create VPC
resource "aws_vpc" "kane" {
  tags {
    Name = "Kane - VPC"
  }
  cidr_block = "11.1.0.0/16"
}

resource "aws_subnet" "web" {
  vpc_id     = "${aws_vpc.kane.id}"
  cidr_block = "11.1.1.0/24"
  map_public_ip_on_launch = true
  tags {
    Name = "Web - Public"
  }
}

resource "aws_subnet" "db" {
  vpc_id     = "${aws_vpc.kane.id}"
  cidr_block = "11.1.2.0/24"
  map_public_ip_on_launch = false
  tags {
    Name = "db - Public"
  }
}

resource "aws_security_group" "http-kane" {
  name        = "http-kane"
  description = "Allow all inbound traffic through port 80 only"
  vpc_id     = "${aws_vpc.kane.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "http-kane"
  }
}

resource "aws_security_group" "db-kane" {
  name        = "db-kane"
  description = "database security group"
  vpc_id     = "${aws_vpc.kane.id}"

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = ["${aws_security_group.http-kane.id}"]
  }
  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "db-kane"
  }
}

data "template_file" "init_script" {
  template = "${file("${path.module}/init.sh")}"
}

# Create a new instance of the latest Ubuntu 14.04 on an
# t2.micro node with an AWS Tag naming it "HelloWorld"
resource "aws_instance" "web-kane" {
  ami           = "${data.aws_ami.kaneweb.id}"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.http-kane.id}"]
  subnet_id = "${aws_subnet.web.id}"
  user_data = "${data.template_file.init_script.rendered}"
  tags {
    Name = "web-kane"
  }
  depends_on = ["aws_instance.db-kane"]
}

#Database instance 
resource "aws_instance" "db-kane" {
  ami           = "ami-afc2d1cb"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.db-kane.id}"]
  subnet_id = "${aws_subnet.db.id}"
  private_ip = "11.1.2.69"

  tags {
    Name = "db-kane"
  }
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Create internet gateway
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.kane.id}"
}

# Add route to internet gateway in route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.kane.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_route_table" "web-table" {
  vpc_id = "${aws_vpc.kane.id}"

}

resource "aws_route_table" "db-table" {
  vpc_id = "${aws_vpc.kane.id}"

}

resource "aws_route_table_association" "web" {
  subnet_id = "${aws_subnet.web.id}"
  route_table_id = "${aws_route_table.web-table.id}"
}

resource "aws_route_table_association" "db" {
  subnet_id = "${aws_subnet.db.id}"
  route_table_id = "${aws_route_table.db-table.id}"
}

