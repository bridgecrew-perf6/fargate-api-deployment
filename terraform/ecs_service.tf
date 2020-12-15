resource "aws_ecs_task_definition" "ecs_task_definition_service" {
  family                   = "${local.service_stage}-${local.service_name}"
  task_role_arn            = aws_iam_role.iam_role.arn
  container_definitions    = data.template_file.service_task_template_service.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.iam_role.arn
  cpu                      = var.task_cpu
  memory                   = var.task_memory
}

resource "aws_ecs_service" "ecs_service" {
  name                               = local.service_name
  scheduling_strategy                = "REPLICA"
  launch_type                        = "FARGATE"
  cluster                            = var.cluster
  task_definition                    = aws_ecs_task_definition.ecs_task_definition_service.arn
  desired_count                      = var.service_desired_count
  health_check_grace_period_seconds  = "0"
  deployment_minimum_healthy_percent = "50"

  load_balancer {
    target_group_arn = aws_alb_target_group.lb_tg_service.arn
    container_name   = local.service_name
    container_port   = var.app_port
  }

  network_configuration {
    subnets = [aws_subnet.public_subnet.id]

    security_groups = [
      aws_security_group.app_sg.id,
      aws_security_group.lb_sg.id,
    ]

    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_appautoscaling_target" "service_target_service" {
  max_capacity       = "5"
  min_capacity       = "1"
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  role_arn           = aws_iam_role.iam_role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "service_scaling_policy_service" {
  name               = "${local.service_name}_scaling_policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.service_target_service.resource_id
  scalable_dimension = aws_appautoscaling_target.service_target_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.service_target_service.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50 # This is the value (%) that the alarm will track and activate the scale in or out, based on CPU utilization
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

