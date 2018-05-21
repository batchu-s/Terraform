resource "aws_instance" "example" {
	instance_type = "t2.micro"
	ami = "${lookup(var.AMIS, var.AWS_REGION)}"
	provisioner "local-exec" {
		command = "echo ${aws_instance.example.private_ip} >> private_ips.txt"
	}
}

output "ip" {
	value = "${aws_instance.example.public_ip}"
}
