provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "mn.xxwmm.marketing.terraformstate.remrqszkdw"
    key    = "basketgateway-stub/iam/iam-statefile"
    region = "eu-west-1"
  }
}

################################################
###### IAM - Role                          #####
################################################

resource "aws_iam_role" "role" {
  name = "rol-glob-${var.environment}-${var.owner_name}-${var.application_service}-${var.seq_id}"  
  description = "${var.application_service} Service IAM Role"
  
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
	  "ecs.amazonaws.com",
	  "ec2.amazonaws.com"
	]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

output "iam_role_name" {
  value = aws_iam_role.role.name
}

################################################
###### IAM - Policy Json File              #####
################################################

data "template_file" "policy" {
  template = file("policies/servicepolicy.json")
}

################################################
###### IAM - Policy                        #####
################################################

resource "aws_iam_policy" "servicepolicy" {
  name = "pol-glob-${var.environment}-${var.owner_name}-${var.application_service}-${var.seq_id}"
  description = "${var.application_service} Service IAM Policy"
  policy = data.template_file.policy.rendered
}

output "iam_policy_name" {
  value = aws_iam_policy.servicepolicy.name
}

################################################
###### IAM - Policy Attachment             #####
################################################

resource "aws_iam_policy_attachment" "servicepolicy-attach" {
  name       = "servicepolicy-attachment"
  #users      = ["${aws_iam_user.user.name}"]
  roles      = [aws_iam_role.role.name]
  #groups     = aws_iam_group.group.name
  policy_arn = aws_iam_policy.servicepolicy.arn
  depends_on = [
    aws_iam_role.role
    ]
}



