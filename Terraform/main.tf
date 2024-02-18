provider "aws" {
  region     = "eu-west-1"
}

resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "default_vpc"
  }
}

data "aws_availability_zones" "available_zones" {
  
}

resource "aws_default_subnet" "subnet_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

resource "aws_default_subnet" "subnet_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}


resource "aws_security_group" "allow_mssql" {
  name        = "allow_mssql"

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_mssql"
    owner         = "Umang-Vadadoriya@bbd.co.za"
    createdusing = "terraform-github"
  }
}

variable "DATABASE_USERNAME" {
  type = string
  description = "The username of database"
}
variable "DATABASE_PASSWORD" {
  type = string
  description = "The password of database"
}

resource "aws_db_instance" "tutordb" {
  identifier             = "tutordb"
  engine                 = "sqlserver-ex"
  engine_version         = "14.00.3465.1.v1"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  publicly_accessible    = true
  username               = var.DATABASE_USERNAME
  password               = var.DATABASE_PASSWORD
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.allow_mssql.id]
  provisioner "local-exec" {
    command = "sqlcmd -S ${aws_db_instance.tutordb.endpoint},${aws_db_instance.tutordb.port} -U ${self.username} -P ${self.password} -Q 'CREATE DATABASE my_database;'"
  }
  tags = {
    owner         = "Umang-Vadadoriya@bbd.co.za"
    createdusing = "terraform-github"
  }

}

# resource "aws_rds_database" "my_db" {
#   name         = "my_database"
#   engine       = aws_db_instance.tutordb.engine
#   instance_arn = aws_db_instance.tutordb.arn
# }