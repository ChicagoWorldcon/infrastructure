resource "aws_iam_role" "registration" {
  name = "registration"
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
  name = "registration_instance_profile"
  role = "${aws_iam_role.registration.name}"
}

resource "aws_iam_role_policy" "registration" {
  name = "reg_iam_role_policy"
  role = "${aws_iam_role.registration.name}"
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
        }
    ]
}
EOF
}

