provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "main" {
  name = "ecs-cluster"
}

#IAM Role for ECS tasks 
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

#Attaching policies to the IAM role above
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


#log group for ECS containers to push their logs
resource "aws_cloudwatch_log_group" "ecs_log" {
  name = "/ecs/nginx"
}

#ECS task definition 
resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  #FARGATE, EC2 or external
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([{
    #container image
    name      = "nginx"
    image     = "nginx:latest"
    essential = true

    #port Mapping (earlier we opened the port 80 in the sg)
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    #logs go to cloudwatch /ecs/nginx/nginx/....
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_log.name
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "nginx"
      }
    }
  }])
}

#Fargate service 
resource "aws_ecs_service" "nginx" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  #1 instance
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}
