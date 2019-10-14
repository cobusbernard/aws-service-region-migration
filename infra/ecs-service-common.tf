# Now that we have a cluster and a CodePipeline, it needs to be able to deploy somewhere. For this, we need to define a task that can be used to run an ECS service.
# This requires:
# 1. An ECS task definition (which container, cpu & ram requirements, etc)
# 2. An ECS service definition (how many of a task to run)
# 3. IAM Role for ECS to execute as - this grants ECS service permission to interact with AWS resources like the Target Groups.
# 4. IAM Role for the ECS task definition - this grans the container permission to interact with AWS resources.
# 5. A log group to send logs to

resource "aws_cloudwatch_log_group" "webinar_app" {
  name = "${var.ecs_cluster_name}-logs"
}

# IAM Roles
## ECS Execution
resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs_execution_role"
  assume_role_policy = "${file("templates/ecs_execution_iam_role_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy_ecs_main" {
  role       = "${aws_iam_role.ecs_execution_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## ECS Task
resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs_task_role"
  assume_role_policy = "${file("templates/ecs_task_run_iam_role_policy.json")}"
}

data "template_file" "ecs_task_role_policy" {
  template = "${file("templates/ecs_task_run_iam_policy.json")}"
}

resource "aws_iam_policy" "ecs_task_role_policy" {
  name        = "ecs_task_role_policy"
  path        = "/"
  description = "Policy to run the ${var.container_name} task"

  policy = "${data.template_file.ecs_task_role_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = "${aws_iam_role.ecs_task_role.id}"
  policy_arn = "${aws_iam_policy.ecs_task_role_policy.arn}"
}
