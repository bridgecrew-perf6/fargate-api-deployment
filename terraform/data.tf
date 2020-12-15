data "template_file" "service_interpoled_vars" {
  template = file("${path.module}/templates/environment-vars.json")

  vars = {
    environment = local.service_stage
    region      = var.aws_region
    lb_dns      = aws_lb.lb.dns_name
  }
}

data "template_file" "service_task_template_service" {
  template = file("${path.module}/templates/service-task-definition-service.tpl")

  vars = {
    environment      = local.service_stage
    service-name     = local.service_name
    region           = var.aws_region
    environment-vars = data.template_file.service_interpoled_vars.rendered
    lb_dns           = aws_lb.lb.dns_name
    role_arn         = aws_iam_role.iam_role.arn
  }
}

