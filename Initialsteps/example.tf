# Configure the aws provider
provider "aws" {
	shared_credentials_file	= "/home/ubuntu/.creds"
	region			= "us-east-1"
	profile			= "defaults"
}

# Create a web server
resource "aws_instance" "web-server" {
	ami		= "ami-43a15f3e"
	instance_type	= "t2.micro"
	key_name	= "crack"
}
