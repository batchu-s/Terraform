# Terraform
What is Terraform?
Terraform is a provisioning tool.
- infrastructure as code
- automation of infrastructure
- keep your infrastucture in a certain state. (Ex: 2 web instances, 2 volumes and 1 LoadBalancer)
- the code can be auditable in any VCS like git

Installing Terraform:
wget https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
mkdir terraform
cd terraform
unzip ../https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip
export PATH=$PATH:/home/ubuntu/terraform

Terraform first steps:

terraform apply --> terraform plan -out out.terraform + terraform apply out.terraform *** Highly recommended to use it in production
terraform plan --> this command will not apply any changes on the cloud but shows the changes that it is going to make
terraform apply --> this command will directly applied on the infrastructure
terraform destroy --> this command is used to destroy the infrastructure in the provider cloud

Terraform first example:
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


Variables in terraform:

- used to hide secrets
- used to store the data that might change
- used to make yourself easy to reuse terraform files

We have to seperate the terraform file into different files in order to use variables.

provider.tf --> this file contains the data of the cloud provider
provider "aws" {
	access_key = "${var.AWS_ACCESS_KEY}"
	secret_key = "${var.AWS_SECRET_KEY}"
	region = "${var.AWS_REGION}"
}

vars.tf --> In this file we declare the variables we needed
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
	default = "us-east-1"
}
variable "AMIS" {
	type = "map"
	default = {
		us-east-1 = "ami-xxxxxx"
		us-west-1 = "ami-xxxxxx"
		us-west-2 = "ami-xxxxxx"
	}
}

terraform.tfvars --> In this file we define the variables
AWS_ACCESS_KEY = "<Access-key>"
AWS_SECRET_KEY = "<Secret-key>"
AWS_REGION = "<Region>"

instance.tf --> In this file we will write our instance details
resource "aws_instance" "example" {
	ami = "${lookup(var.AMIS, var.AWS_REGION)}"
	instance_type = "t2.micro"
}

Website to look for images: https://cloud-images.ubuntu.com/locator/ec2/

Provisioning software in instances:
This can be done in two ways.
1. Packer --> build your custom AMI
2. Launch Standard AMIs
	- using file uploads
	- using remote-exec
	- using automation tools like chef, puppet, ansible

By using second method let's try to provision software using file uploads and remote-exec
resource "aws_key_pair" "mykey" {
	key_name = "mykey"
	public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}
resource "aws_instance" "example-instance" {
	ami = "${lookup(var.AMIS, var.AWS_REGION)}"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.mykey.key_name}"

	provisioner "file" {
		source = "script.sh"
		destination = "/tmp/script.sh"
	}

	provisioner "remote-exec" {
		inline = [
			"chmod +x /tmp/script.sh",
			"sudo /tmp/script.sh"
		]
	}

	connection {
		user = "${var.INSTANCE_USERNAME}"
		private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
	}
}

and the vars.tf file looks like this:
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

Outputting attributes: For outputting attributes of the resources we use output module and to execute any command in the local machine use local-exec
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


Now it's time to add the backend of the terraform to maintain the terraform state

terraform {
        backend "s3" {
                bucket = "terraform-state-05212018"
                key = "terraform/backend"
        }
}

The state of our stack is stored in s3 bucket where we can track it.

DataSources:
- For certain providers like AWS, terraform provides datasources.
- Datasources provide you with dynamic information
	- A lot of data is available by AWS in a structured format using their API.
	- Terraform also exposes this information using data sources.
- Examples:
	- List of AMIs
	- List of Availability Zones
The following is a great example of datasource that gives you all IP addresses in use by AWS.
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
} --> It creates a security group with "from_usa" as name and adding the inbound rules of different ip ranges(CIDR blocks).

Terraform Templates:




