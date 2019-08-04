variable "extension_url" {
  description = "authorization_extension api url"
}

variable "application_type" {
  description = "AWS or Jenkins"
}
variable "aws_account_id" {
  description = "AWS account id with your saml provider"
  default = ""
}

variable "application_name" {
  description = "Application name on auth0 dashboard"
}

variable "aws_saml_provider" {
  description = "AWS saml provider name"
  default = ""
}

variable "jenkins_url" {
  description = "Jenkins Realm Url"
  default = ""
}