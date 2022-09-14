resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
}

resource "aws_ecs_task_definition" "main" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

}