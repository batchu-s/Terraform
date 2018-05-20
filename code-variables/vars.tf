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
