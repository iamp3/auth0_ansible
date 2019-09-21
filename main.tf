provider "auth0" {  
  domain = "dev-prom.auth0.com"
  client_id = "XXX"
  client_secret = "XXX"
}

provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile = "lod"
  region = "us-east-1"
}

module "aws" {
    source = "./modules/auth_ext"
    extension_url = "https://dev-prom.us8.webtask.io/adf6e2f2b84784b57522e3b19dfc9201"
    aws_saml_provider = "auth0_dev"
    aws_account_id = "553748148142"
    application_type = "aws"
    application_name = "aws"
    domain_name = "dev-prom"
}

module "jenkins" {
    source = "./modules/auth_ext"
    extension_url = "https://dev-prom.us8.webtask.io/adf6e2f2b84784b57522e3b19dfc9201"
    jenkins_url = "http://ec2-3-82-100-188.compute-1.amazonaws.com"
    application_type = "jenkins"
    application_name = "jenkins"
    domain_name = "dev-prom"
}