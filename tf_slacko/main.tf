data "aws_ami" "slacko-amazon" {

 most_recent      = true

 owners           = ["amazon"]

  


 filter {

   name   = "name"

   values = ["amzn2-ami*"]

 }



 filter {

   name   = "architecture"

   values = ["x86_64"]

 }



 filter {

   name   = "virtualization-type"

   values = ["hvm"]

 }

}



data "aws_subnet" "slacko-app-subnet-public" {

   cidr_block = "10.0.102.0/24"

}



resource "aws_key_pair" "slacko-key-ssh" {

 key_name = "slacko-ssh-key"

 public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEnCDyP98iRAbY9y0lKZG+FRqqfnI+rj7rMKdE21QYSFVASm33E6KfPL2Ln4V+gBfHaIUNfvyU5rQhwyWcyBqMM1QYodadgl8c0z8OLMFo5+poVuyYZrJxzaS0UQv4pVg31dzOmSPzLNUvAZf3+xXH6Kq2DMTT0jQFSVHHg0PR0JOn8kMVQYw5G5rpeTR9XVrTAetLIZR/IZWufA62er8LD51pkrMD0BiGhP4x7WtVgQ0hWK4jbEwlhGkYCgTcznL5nxCDNgq63xpLga4zO4G1mD3CEQl8y86Ue8Ay1DtPR3oMBPkbKpw+OpMxtk4oqvN1YnSDHAafYGpM5m9Em86/MTOFeFdjYKaFrbQgyewAevUMITQ+D7aLW9slb7Z2gcdaAlFYfoeJy5UdQomlvqevbpMJefD5oJu+sF57HdEIItGdmPnmruqg9AO991nIgW2AyaeIsve4OEjMQ9IyxsYBgvC+2aixJ+Q5VgkJMw6eJCrOgSfVkj1qEGdm08XRHVU= slacko"



}



resource "aws_instance" "slacko-app" {

  ami = data.aws_ami.slacko-amazon.id

  instance_type = "t2.micro"

  subnet_id = data.aws_subnet.slacko-app-subnet-public.id

  associate_public_ip_address = true

  key_name = aws_key_pair.slacko-key-ssh.key_name

  user_data = file("ec2.sh")

  tags = {

      Name = "slacko-app"

    }  
}



resource "aws_instance" "slacko-mongodb" {

  ami = data.aws_ami.slacko-amazon.id

  instance_type = "t2.small"

  subnet_id = data.aws_subnet.slacko-app-subnet-public.id

  associate_public_ip_address = true

  key_name = aws_key_pair.slacko-key-ssh.key_name

  user_data = file("mongodb.sh")  
  tags = {

      Name = "slacko-mongodb"

    }  
}



resource "aws_security_group" "allow-http-ssh" {

name = "allow_http_ssh"

description = "Security group allows SSH and HTTP"

vpc_id = "vpc-0c07086c5f321dfd6"



 ingress = [

    {

      description = "Allowe SSH"

      from_port = 22

      to_port = 22

      protocol = "tcp"

      cidr_blocks = ["0.0.0.0/0"]

      ipv6_cidr_blocks = []

      prefix_list_ids = []

      security_groups = []

      self = null

    },

    {

      description = "Allowe HTTP"

      from_port = 80

      to_port = 80

      protocol = "tcp"

      cidr_blocks = ["0.0.0.0/0"]

      ipv6_cidr_blocks = []

      prefix_list_ids = []

      security_groups = []

      self = null

    }

 ]



egress = [

 {

   description = "Allowe HTTP"

   from_port = 0

   to_port = 0

   protocol = "tcp"

   cidr_blocks = ["0.0.0.0/0"]

   ipv6_cidr_blocks = []

   prefix_list_ids = []

   security_groups = []

   self = null

 }      
 ]

 tags = {

      Name = "allow_ssh_http"

  }

}



resource "aws_network_interface_sg_attachment" "slacko-sg" {

  security_group_id = aws_security_group.allow-http-ssh.id

  network_interface_id = aws_instance.slacko-app.primary_network_interface_id

}





output "slacko-app-IP" {

  value = aws_instance.slacko-app.public_ip

}



output "slacko-mongodb-ip" {

 value = aws_instance.slacko-mongodb.private_ip

}