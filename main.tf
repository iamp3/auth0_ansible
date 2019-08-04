provider "auth0" {  
  domain = "dev-prom.auth0.com"
  client_id = "vY2ixUH3W2FVAJ4u9YROelG2UfIzzI91"
  client_secret = "-JnFRoJ22gi5vitgvMW21MdZbRssFYjb7USbVMtxdeWeX8jy_08b8zUTrxiRKWpN"
}
module "aws" {
    source = "./modules/auth_ext"
    extension_url = "https://dev-prom.us8.webtask.io/adf6e2f2b84784b57522e3b19dfc9201"
    aws_saml_provider = "auth0_dev"
    aws_account_id = "553748148142"
    application_type = "aws"
    application_name = "aws"
}

module "jenkins" {
    source = "./modules/auth_ext"
    extension_url = "https://dev-prom.us8.webtask.io/adf6e2f2b84784b57522e3b19dfc9201"
    jenkins_url = "http://ec2-3-82-100-188.compute-1.amazonaws.com"
    application_type = "jenkins"
    application_name = "jenkins"
}