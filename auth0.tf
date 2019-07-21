provider "auth0" {  
  domain = ""
  client_id = ""
  client_secret = ""
}

resource "auth0_client" "AWS" {
  name            = "AWS"
  description     = "AWS"
  app_type        = "spa"
  is_first_party  = true
  oidc_conformant = true
  grant_types     = ["authorization_code", "http://auth0.com/oauth/grant-type/password-realm", "implicit", "password", "refresh_token"]
  callbacks       = ["https://signin.aws.amazon.com/saml"]


   jwt_configuration = {
    lifetime_in_seconds = 120
    secret_encoded      = true
    alg                 = "RS256"
  }

  custom_login_page_on = "true"
 
  addons = {
    samlp = {
      audience = "https://signin.aws.amazon.com/saml",
      mappings = {
        email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
        name = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
      },
      create_upn_claim = false,
      passthrough_claims_with_no_mapping = true,
      map_unknown_claims_as_is = false,
      map_identities = false,
      name_identifier_format = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
      name_identifier_probes = [
        "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
      ]
    }
  }
}

# resource "auth0_rule" "auth0-authorization-extension-aws" {
#   name = "auth0-authorization-extension-aws"
#   script = <<EOF
# function (user, context, callback) {
#   var _ = require('lodash');
#   var EXTENSION_URL = "https://dev-lod.eu8.webtask.io/adf6e2f2b84784b57522e3b19dfc9201";

#   var audience = '';
#   audience = audience || (context.request && context.request.query && context.request.query.audience);
#   if (audience === 'urn:auth0-authz-api') {
#     return callback(new UnauthorizedError('no_end_users'));
#   }

#   audience = audience || (context.request && context.request.body && context.request.body.audience);
#   if (audience === 'urn:auth0-authz-api') {
#     return callback(new UnauthorizedError('no_end_users'));
#   }

#   getPolicy(user, context, function(err, res, data) {
#     if (err) {
#       console.log('Error from Authorization Extension:', err);
#       return callback(new UnauthorizedError('Authorization Extension: ' + err.message));
#     }

#     if (res.statusCode !== 200) {
#       console.log('Error from Authorization Extension:', res.body || res.statusCode);
#       return callback(
#         new UnauthorizedError('Authorization Extension: ' + ((res.body && (res.body.message || res.body) || res.statusCode)))
#       );
#     }

#     // Update the user object.
#     user.groups = data.groups;

#     var group;
#     function groupCheck(value){
#       return value === group;
#     }

#     group = 'admin';
#     if(user.groups.find(groupCheck)){
#       user.awsRole = 'arn:aws:iam::553748148142:role/admin,arn:aws:iam::553748148142:saml-provider/auth0';
#     }

#     group = 'dev';
#     if(user.groups.find(groupCheck)){
#       user.awsRole = 'arn:aws:iam::553748148142:role/dev,arn:aws:iam::553748148142:saml-provider/auth0';
#     } 

#     user.awsRoleSession = user.name;

#   context.samlConfiguration.mappings = {
#     'https://aws.amazon.com/SAML/Attributes/Role': 'awsRole',
#     'https://aws.amazon.com/SAML/Attributes/RoleSessionName': 'awsRoleSession'
#   };
#     return callback(null, user, context);
#   });
  
#   // Convert groups to array
#   function parseGroups(data) {
#     if (typeof data === 'string') {
#       // split groups represented as string by spaces and/or comma
#       return data.replace(/,/g, ' ').replace(/\s+/g, ' ').split(' ');
#     }
#     return data;
#   }

#   // Get the policy for the user.
#   function getPolicy(user, context, cb) {
#     request.post({
#       url: EXTENSION_URL + "/api/users/" + user.user_id + "/policy/" + context.clientID,
#       headers: {
#         "x-api-key": configuration.AUTHZ_EXT_API_KEY
#       },
#       json: {
#         connectionName: context.connection || user.identities[0].connection,
#         groups: parseGroups(user.groups)
#       },
#       timeout: 5000
#     }, cb);
#   }
# }
# EOF
#   enabled = true
# }
