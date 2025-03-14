# aws-ecs.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "cluster" {
  name = "ai-ecs-cluster"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "ai-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "ai-service"
      image     = "your-dockerhub-username/ai-service:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "ai-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-xxxxxx"]
    assign_public_ip = true
    security_groups = ["sg-xxxxxx"]
  }
}
