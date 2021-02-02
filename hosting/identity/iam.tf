resource "aws_iam_role" "instance" {
  name               = "${var.project}-${var.application}-${var.stage}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
     "Effect": "Allow",
     "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.project}-${var.application}-instance-profile-${var.stage}"
  role = aws_iam_role.instance.name
}

data "template_file" "hosting-role-policy" {
  template = file("${path.module}/policies/instance-policy.json")

  vars = {
    stage               = var.stage
    zone_id             = var.route53_zone_id
    codepipeline_bucket = var.codepipeline_bucket
    codedeploy_bucket   = var.codedeploy_bucket
  }
}

resource "aws_iam_role_policy" "instance" {
  name   = "${var.project}-${var.application}-policy-${var.stage}"
  role   = aws_iam_role.instance.name
  policy = data.template_file.hosting-role-policy.rendered
}

resource "aws_iam_role_policy" "deployment" {
  name   = "${var.project}-api-deployment-policy"
  role   = aws_iam_role.instance.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codedeploy:*"
            ],
            "Resource": [
                "arn:aws:codedeploy:us-west-2:984616268605:*"
            ]
        }
    ]
}
EOF
}
