resource "aws_ecs_cluster" "aws_ecs_cluster" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_ecs_cluster" "aws_ecs_cluster_new" {
provider = aws.new

  name = "${var.ecs_cluster_name}"
}
