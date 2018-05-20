resource "aws_instance" "example-instance" {
	ami = "${lookup(var.AMIS, var.AWS_REGION)}"
	instance-type = "t2.micro"
}
