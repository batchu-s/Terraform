resource "aws_launch_configuration" "webcluster" {
  image_id = "${var.image_id}"
  instance_type = "${var.instance_type}"
  security_groups = ["${var.security_group_id}"]
  key_name = "${var.key_name}"
  lifecycle {
    create_before_destroy = true
  }	
}

data "aws_availability_zones" "allzones" { }

resource "aws_autoscaling_group" "scalegroup" {
  launch_configuration = "${aws_launch_configuration.webcluster.name}"
  min_size = 1
  max_size = 3
  vpc_zone_identifier = ["${var.subnet_id}"]
  enabled_metrics = ["GroupMinSize","GroupMaxSize","GroupDesiredCapacity","GroupInServiceInstances","GroupTotalInstances"]
  load_balancers = ["${aws_elb.elb1.id}"]
  health_check_type = "ELB"
  tags = [
    {
      key = "Name"
      value = "terraform-asg"
      propagate_at_laund = true
    }
  ]
}

resource "aws_autoscaling_policy" "autoploicy" {
  name = "terraform-policy"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.scalegroup.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpualarm" {
  alarm_name = "terraform-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "60"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.scalegroup.name}"
  }
  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions = ["${aws_autoscaling_policy.autopolicy.arn}"]
}

resource "aws_autoscaling_policy" "autopolicy-down" {
  name = "terraform-autoplicy-down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.scalegroup.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpualarm-down" {
  alarm_name = "terraform-alarm-down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "10"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.scalegroup.name}"
  }

  alarm_description = "This metric monitor EC2 instance cpu utilization"
  alarm_actions = ["${aws_autoscaling_policy.autopolicy-down.arn}"]
}

resource "aws_elb" "elb1" {
  name = "terraform-elb"
  availability_zones = ["${data.aws_availability_zones.allzones.names}"]
  security_groups = ["${var.elb_sg_id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  
  tags {
    Name = "terraform-elb"
  }

}

output "availabilityzones" {
  value = ["${data.aws_availability_zones.allzones.names}"]
}

output "elb-dns" {
  value = "${aws_elb.elb1.dns_name}"
}

