terraform {
  backend "s3" {
    bucket = "${var.bucket_name}"
    key = "terraform/java_server/backend"
    region = "${var.region}"
  }
}
