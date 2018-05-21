terraform {
	backend "s3" {
		bucket = "terraform-state-05212018"
		key = "terraform/backend"
	}
}
