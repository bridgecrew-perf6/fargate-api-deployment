resource "aws_lb" "lb" {
  name               = "service-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets = [
    aws_subnet.public_subnet.id,
    aws_subnet.private_subnet.id
  ]

  enable_deletion_protection = false

  tags = {
    Environment = local.service_stage
  }
}

resource "aws_alb_target_group" "lb_tg_service" {
  name                 = "${local.service_stage}-service-lb-tg"
  port                 = var.app_port
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = 0
  target_type          = "ip"

  health_check {
    path     = "/healthcheck"
    matcher  = "200"
    interval = "10"
  }

  tags = {
    environment = local.service_stage
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "lb_listener_service" {
  load_balancer_arn = aws_lb.lb.arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.lb_tg_service.arn
  }
}

