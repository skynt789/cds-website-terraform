resource "aws_ecs_cluster" "website-cms-cluster" {
  name = "website-cms-cluster"
}

data "template_file" "cms_app" {
  template = file("./task-definitions/cms_app.json.tpl")

  vars = {
    app_image      = var.app_image
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = "ca-central-1"
  }
}

resource "aws_ecs_service" "website-cms-ecs" {
  name          = "website-cms-ecs"
  cluster       = "website-cms-cluster"
  desired_count = 1
  launch_type   = FARGATE

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.cms-website-private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "cds-website-cms"
    container_port   = var.app_port
  }
}