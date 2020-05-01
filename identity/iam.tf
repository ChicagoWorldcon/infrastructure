resource "aws_iam_role" "registration" {
  name               = "${var.project}-registration-${var.stage}"
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

resource "aws_iam_instance_profile" "registration" {
  name = "${var.project}-registration-instance-profile-${var.stage}"
  role = aws_iam_role.registration.name
}

resource "aws_iam_role_policy" "registration" {
  name   = "${var.project}-registration-policy-${var.stage}"
  role   = aws_iam_role.registration.name
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:ListSecrets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect" : "Allow",
            "Action" : [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource" : [
                "arn:aws:route53:::hostedzone/${var.route53_zone_id}"
            ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:Get*",
            "s3:List*"
          ],
          "Resource": [
            "arn:aws:s3:::${var.codepipeline_bucket}/*",
            "arn:aws:s3:::${var.codedeploy_bucket}/*"
          ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "deployment" {
  name   = "${var.project}-api-deployment-policy"
  role   = aws_iam_role.registration.name
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
