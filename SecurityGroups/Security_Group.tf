data "aws_ip_ranges" "from_usa_ec2" {
	regions = ["us-east-1"]
	services = ["ec2"]
}

resource "aws_security_group" "from_usa" {
	name = "from_usa"
	
	ingress {
		from_port = "443"
		to_port = "443"
		protocol = "tcp"
		cidr_blocks = ["${data.aws_ip_ranges.from_usa_ec2.cidr_blocks}"]
	}

	tags {
		CreateDate = "${data.aws_ip_ranges.from_usa_ec2.create_date}"
		SyncToken = "${data.aws_ip_ranges.from_usa_ec2.sync_token}"
	}
}
