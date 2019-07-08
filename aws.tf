terraform {
  backend "s3" {
    bucket = "lod-tfstate-bucket"    
    key    = "terraform.tfstate"
    shared_credentials_file = "~/.aws/credentials"
    profile = "lod"
    region = "us-east-1"
  }
}

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile = "lod"
  region = "us-east-1"
}
resource "aws_iam_user" "auth0" {
  name = "auth0-user"
}

## SAML provider 
resource "aws_iam_saml_provider" "auth0" {
  name                   = "auth0"
  saml_metadata_document = "${file("saml-metadata.xml")}"
}

## IAM Role
resource "aws_iam_role" "auth0" {
  name = "auth0_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_saml_provider.auth0.arn}"
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

resource "aws_iam_policy" "auth0" {
  name        = "auth0-policy"
  description = "auth0-policy"
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

resource "aws_iam_policy_attachment" "auth0-attach" {
  name       = "auth0-attachment"
  users      = ["${aws_iam_user.auth0.name}"]
  roles      = ["${aws_iam_role.auth0.name}"]
  policy_arn = "${aws_iam_policy.auth0.arn}"
}