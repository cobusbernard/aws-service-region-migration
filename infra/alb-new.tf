# To expose the container to the internet, we will be using an Application Load-Balancer (ALB).
# To be able to route traffic to our containers, we create a target group and regsiter the containers with it. 
# We then have the ALB route traffic to the target group.
# We require the following components for it:
# 1. A target group
# 2. An ALB
# 3. A security group for the ALB to define how it may be accessed.

resource "aws_security_group" "alb_new" {
  provider = aws.new

  name        = "alb-${var.alb_name}"
  description = "ALB Security Group."
  vpc_id      = "${module.vpc_new.vpc_id}"

  tags = {
    Name = "alb-${var.alb_name}"
  }
}

resource "aws_security_group_rule" "alb_allow_http_new" {
  provider = aws.new

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.alb_new.id}"
}

resource "aws_security_group_rule" "alb_allow_egress_new" {
  provider = aws.new

  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.alb_new.id}"
}

resource "aws_alb_target_group" "webinar_service_target_group_new" {
  provider = aws.new

  name                 = "${var.container_name}-target-group"
  port                 = "${var.container_port}"
  protocol             = "HTTP"
  vpc_id               = "${module.vpc_new.vpc_id}"
  target_type          = "ip"
  deregistration_delay = 10

  health_check {
    interval          = 5
    timeout           = 4
    healthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_alb.webinar_alb_new"]
}

resource "aws_alb" "webinar_alb_new" {
  provider = aws.new

  name            = "${var.alb_name}"
  subnets         = "${module.vpc_new.public_subnets}"
  security_groups = ["${aws_security_group.alb_new.id}"]
}

resource "aws_alb_listener" "webinar_app_new" {
  provider = aws.new

  load_balancer_arn = "${aws_alb.webinar_alb_new.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.webinar_service_target_group_new.arn}"
    type             = "forward"
  }
}
