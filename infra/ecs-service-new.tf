# Now that we have a cluster and a CodePipeline, it needs to be able to deploy somewhere. For this, we need to define a task that can be used to run an ECS service.
# This requires:
# 1. An ECS task definition (which container, cpu & ram requirements, etc)
# 2. An ECS service definition (how many of a task to run)
# 3. IAM Role for ECS to execute as - this grants ECS service permission to interact with AWS resources like the Target Groups.
# 4. IAM Role for the ECS task definition - this grans the container permission to interact with AWS resources.
# 5. A log group to send logs to


data "template_file" "webinar_task_new" {
  template = "${file("templates/webinar_task.json")}"

  vars = {
    aws_region          = "${var.aws_region_new}"
    image               = "${aws_ecr_repository.webinar_repo_new.repository_url}"
    container_name      = "${var.container_name}"
    container_port      = "${var.container_port}"
    log_group           = "${aws_cloudwatch_log_group.webinar_app.name}"
    desired_task_cpu    = "${var.container_desired_cpu}"
    desired_task_memory = "${var.container_desired_memory}"
  }
}


resource "aws_ecs_task_definition" "webinar_new" {
  provider = aws.new

  family                   = "${var.container_name}"
  container_definitions    = "${data.template_file.webinar_task_new.rendered}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "${var.container_desired_cpu}"
  memory                   = "${var.container_desired_memory}"

  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  #  task_role_arn      = "${aws_iam_role.ecs_task_role.arn}"
}

resource "aws_security_group" "webinar_service_new" {
  provider = aws.new

  name        = "ecs-service-${var.alb_name}"
  description = "ALB Security Group."
  vpc_id      = "${module.vpc_new.vpc_id}"

  tags = {
    Name = "alb-${var.alb_name}"
  }
}

resource "aws_security_group_rule" "webinar_service_allow_http_new" {
  provider = aws.new

  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.alb_new.id}"

  security_group_id = "${aws_security_group.webinar_service_new.id}"
}

resource "aws_security_group_rule" "webinar_service_allow_egress_new" {
  provider = aws.new

  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.webinar_service_new.id}"
}

data "aws_ecs_task_definition" "webinar_current_new" {
  provider = aws.new

  task_definition = "${aws_ecs_task_definition.webinar_new.family}"
}

resource "aws_ecs_service" "webinar_new" {
  provider = aws.new

  name            = "${var.container_name}"
  task_definition = "${aws_ecs_task_definition.webinar_new.family}:${max("${aws_ecs_task_definition.webinar_new.revision}", "${data.aws_ecs_task_definition.webinar_current_new.revision}")}"

  cluster         = "${aws_ecs_cluster.aws_ecs_cluster_new.id}"
  launch_type     = "FARGATE"
  desired_count   = "${var.container_desired_count}"

  network_configuration {
    security_groups  = ["${aws_security_group.webinar_service_new.id}"]
    subnets          = "${module.vpc_new.private_subnets}"
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.webinar_service_target_group_new.arn}"
    container_name   = "${var.container_name}"
    container_port   = "${var.container_port}"
  }
}