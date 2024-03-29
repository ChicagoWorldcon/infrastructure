resource "aws_iam_role" "instance" {
  name               = "${var.project}-${lower(var.application)}-${lower(var.stage)}"
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
  name = "${var.project}-${lower(var.application)}-instance-profile-${lower(var.stage)}"
  role = aws_iam_role.instance.name
}

resource "aws_iam_role_policy" "instance" {
  name = "${var.project}-${lower(var.application)}-policy-${lower(var.stage)}"
  role = aws_iam_role.instance.name
  policy = templatefile("${path.module}/policies/instance-policy.json", {
    stage               = lower(var.stage)
    zone_id             = var.route53_zone_id
    codepipeline_bucket = var.codepipeline_bucket
    codedeploy_bucket   = var.codedeploy_bucket
    allow_global_access = var.allow_global_access
  })
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
