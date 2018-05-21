variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
	default = "us-east-1"
}
variable "AMIS" {
	type = "map"
	default = {
		us-east-1 = "ami-5c66ea23"
		us-west-1 = "ami-44273924"
		us-west-2 = "ami-b5ed9ccd"
	}
}
variable "PATH_TO_PUBLIC_KEY" {
	default = "mykey.pub"
}
variable "PATH_TO_PRIVATE_KEY" {
	default = "mykey"
}
variable "INSTANCE_USERNAME" {
	default = "ubuntu"
}
