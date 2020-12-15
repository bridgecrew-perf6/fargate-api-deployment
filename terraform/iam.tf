resource "aws_iam_role" "iam_role" {
  name               = "${local.service_stage}-${local.service_name}-role"
  assume_role_policy = file("${path.module}/templates/assume-role-policy.json")
}

resource "aws_iam_role_policy" "iam_policy" {
  name   = "${local.service_stage}-${local.service_name}"
  role   = aws_iam_role.iam_role.id
  policy = file("${path.module}/templates/permission-role-policy.json")
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "${local.service_stage}-${local.service_name}-role"
  role = aws_iam_role.iam_role.name
}
