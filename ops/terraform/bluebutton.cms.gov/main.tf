provider "aws" {
  region = "us-east-1"
}

##
# Data providers
##
data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "web" {
  vpc_id = "${var.vpc_id}"
  tags {
    Layer       = "web"
    stack       = "${var.stack}"
    application = "${var.app}"
  }
}

data "aws_subnet" "web" {
  count = "${length(data.aws_subnet_ids.web.ids)}"
  id = "${data.aws_subnet_ids.web.ids[count.index]}"
}

data "aws_subnet_ids" "dmz" {
  vpc_id = "${var.vpc_id}"
  tags {
    Layer       = "dmz"
    stack       = "${var.stack}"
    application = "${var.app}"
  }
}

data "aws_subnet" "dmz" {
  count = "${length(data.aws_subnet_ids.dmz.ids)}"
  id = "${data.aws_subnet_ids.dmz.ids[count.index]}"
}

data "aws_security_group" "vpn" {
  id = "${var.vpn_sg}"
}

data "template_file" "bucket_policy" {
  template = "${file("${path.module}/templates/bucket-policy.json")}"

  vars {
    bucket_name = "${var.bucket_name}"
    nat_gw_cdir = "${var.nat_gw_cdir}"
  }
}

data "template_file" "nginx_conf" {
  template = "${file("${path.module}/templates/nginx.conf")}"

  vars {
    bucket_name = "${var.bucket_name}"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data")}"

  vars {
    # Replace "$" with "\$" since we're embedding this in user_data
    nginx_conf = "${replace(data.template_file.nginx_conf.rendered, "$", "\\$")}"
    env        = "${var.env}"
  }
}

##
# Security groups
##
resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"

  vpc_id = "${var.vpc_id}"
  name   = "bluebutton-static-prod-alb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name        = "bluebutton-static-prod-alb-sg"
    environment = "${var.env}"
  }
}

resource "aws_security_group" "instance_sg" {
  description = "controls direct access to application instances"
  vpc_id      = "${var.vpc_id}"
  name        = "bluebutton-static-prod-instance-sg"

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    security_groups = [
      "${aws_security_group.lb_sg.id}",
    ]
  }

  # health check endpoint
  ingress {
    protocol  = "tcp"
    from_port = 81
    to_port   = 81

    security_groups = [
      "${aws_security_group.lb_sg.id}",
    ]
  }

  # Ingress from CI
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = [
      "${var.ci_cidrs}"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "bluebutton-static-prod-instance-sg"
    environment = "${var.env}"
  }
}

##
# S3 Bucket
##
resource "aws_s3_bucket" "main" {
  bucket = "${var.bucket_name}"
  acl    = "private"
  policy = "${data.template_file.bucket_policy.rendered}"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags {
    Name        = "${var.bucket_name}"
    environment = "${var.env}"
  }
}

##
# ALB
##
resource "aws_alb" "main" {
  name            = "BB-STATIC-PROD-WEBLB"
  internal        = false
  security_groups = ["${aws_security_group.lb_sg.id}"]
  subnets         = ["${data.aws_subnet_ids.dmz.ids}"]

  enable_deletion_protection = true

  tags {
    environment = "${var.env}"
    application = "bluebutton-static"
  }
}

resource "aws_alb_target_group" "main" {
  name                 = "bb-static-prod"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = 60

  health_check {
    interval            = 10
    path                = "/_health"
    port                = 81
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  tags {
    Name        = "bb-static-prod"
    environment = "${var.env}"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.tls_cert_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.main.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "main" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.main.id}"
    type             = "forward"
  }
}

##
# Launch configuration
##
resource "aws_launch_configuration" "app" {
  security_groups = [
    "${aws_security_group.instance_sg.id}",
    "${data.aws_security_group.vpn.id}",
    "${var.ent_tools_sg_id}",
  ]

  key_name                    = "${var.key_name}"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  user_data                   = "${data.template_file.user_data.rendered}"
  associate_public_ip_address = false
  iam_instance_profile        = "${var.instance_profile}"
  name_prefix                 = "bluebutton-static-prod-lc-"

  lifecycle {
    create_before_destroy = true
  }
}

##
# Autoscaling group
##
resource "aws_autoscaling_group" "main" {
  availability_zones        = ["us-east-1a"]
  name                      = "bb-static-prod-${aws_launch_configuration.app.name}"
  desired_capacity          = "${var.asg_desired}"
  max_size                  = "${var.asg_max}"
  min_size                  = "${var.asg_min}"
  min_elb_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = ["${data.aws_subnet_ids.web.ids}"]
  launch_configuration      = "${aws_launch_configuration.app.name}"
  target_group_arns         = ["${aws_alb_target_group.main.arn}"]

  tag {
    key                 = "Name"
    value               = "bluebutton-static-prod"
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = "${var.env}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "high-cpu" {
  name                   = "${var.app}-static-${var.env}-high-cpu-scaleup"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.main.name}"
}

resource "aws_cloudwatch_metric_alarm" "high-cpu" {
  alarm_name          = "${var.app}-static-${var.env}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.main.name}"
  }

  alarm_description = "CPU usage for ${aws_autoscaling_group.main.name} ASG"
  alarm_actions     = ["${aws_autoscaling_policy.high-cpu.arn}"]
}

resource "aws_autoscaling_policy" "low-cpu" {
  name                   = "${var.app}-static-${var.env}-low-cpu-scaledown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.main.name}"
}

resource "aws_cloudwatch_metric_alarm" "low-cpu" {
  alarm_name          = "${var.app}-static-${var.env}-low-cpu"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.main.name}"
  }

  alarm_description = "CPU usage for ${aws_autoscaling_group.main.name} ASG"
  alarm_actions     = ["${aws_autoscaling_policy.low-cpu.arn}"]
}
