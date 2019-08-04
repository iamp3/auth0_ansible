provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile = "lod"
  region = "us-east-1"
}

## SAML provider 
resource "aws_iam_saml_provider" "auth0_dev" {
  name                   = "auth0_dev"
  saml_metadata_document = "${file("saml-metadata.xml")}"
}

## IAM Role
resource "aws_iam_role" "dev" {
  name = "dev"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_saml_provider.auth0_dev.arn}"
      },
      "Action": "sts:AssumeRoleWithSAML",
      "Condition": {
        "StringEquals": {
          "SAML:aud": "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "dev" {
  name        = "dev"
  description = "dev"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iam:GenerateCredentialReport",
                "iam:GenerateServiceLastAccessedDetails",
                "iam:Get*",
                "iam:List*",
                "iam:SimulateCustomPolicy",
                "iam:SimulatePrincipalPolicy"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "dev" {
  name       = "dev"
  roles      = ["${aws_iam_role.dev.name}"]
  policy_arn = "${aws_iam_policy.dev.arn}"
}


