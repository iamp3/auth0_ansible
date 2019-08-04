resource "auth0_client" "aws" {
  count = "${var.application_type == "aws" ? 1 : 0}"
  name            = "${var.application_name}"
  description     = "${var.application_name}"
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
resource "auth0_rule" "aws" {
  count = "${var.application_type == "aws" ? 1 : 0}"
  name = "${var.application_name}"
  script = <<EOF
function (user, context, callback) {
  var _ = require('lodash');
  var EXTENSION_URL = "${var.extension_url}";

  var audience = '';
  audience = audience || (context.request && context.request.query && context.request.query.audience);
  if (audience === 'urn:auth0-authz-api') {
    return callback(new UnauthorizedError('no_end_users'));
  }

  audience = audience || (context.request && context.request.body && context.request.body.audience);
  if (audience === 'urn:auth0-authz-api') {
    return callback(new UnauthorizedError('no_end_users'));
  }

  getPolicy(user, context, function(err, res, data) {
    if (err) {
      console.log('Error from Authorization Extension:', err);
      return callback(new UnauthorizedError('Authorization Extension: ' + err.message));
    }

    if (res.statusCode !== 200) {
      console.log('Error from Authorization Extension:', res.body || res.statusCode);
      return callback(
        new UnauthorizedError('Authorization Extension: ' + ((res.body && (res.body.message || res.body) || res.statusCode)))
      );
    }

    if(context.clientID === "${auth0_client.aws.id}"){
      // Update the user object.
      user.groups = data.groups;
      var aws_groups = user.groups.filter(group => group.match('${var.application_name}') !== null);
      aws_groups.forEach((g,i)=> {
      var newEl = aws_groups[i].replace('${var.application_name}_','');
      aws_groups[i] = `arn:aws:iam::${var.aws_account_id}:role/$${newEl},arn:aws:iam::${var.aws_account_id}:saml-provider/${var.aws_saml_provider}`;});
      user.awsRole = aws_groups;
      user.awsRoleSession = user.name;
      context.samlConfiguration.mappings = {
       'https://aws.amazon.com/SAML/Attributes/Role': 'awsRole',
       'https://aws.amazon.com/SAML/Attributes/RoleSessionName': 'awsRoleSession'
     };
    }
   
    return callback(null, user, context);
  });
  
  // Convert groups to array
  function parseGroups(data) {
    if (typeof data === 'string') {
      // split groups represented as string by spaces and/or comma
      return data.replace(/,/g, ' ').replace(/\s+/g, ' ').split(' ');
    }
    return data;
  }

  // Get the policy for the user.
  function getPolicy(user, context, cb) {
    request.post({
      url: EXTENSION_URL + "/api/users/" + user.user_id + "/policy/" + context.clientID,
      headers: {
        "x-api-key": configuration.AUTHZ_EXT_API_KEY
      },
      json: {
        connectionName: context.connection || user.identities[0].connection,
        groups: parseGroups(user.groups)
      },
      timeout: 5000
    }, cb);
  }
}
EOF
  enabled = true
}

resource "auth0_client" "jenkins" {
  count = "${var.application_type == "jenkins" ? 1 : 0}"
  name            = "${var.application_name}"
  description     = "${var.application_name}"
  app_type        = "regular_web"
  is_first_party  = true
  oidc_conformant = true
  grant_types     = ["authorization_code", "http://auth0.com/oauth/grant-type/password-realm", "implicit", "password", "refresh_token"]
  callbacks       = ["${var.jenkins_url}/securityRealm/finishLogin"]


   jwt_configuration = {
    lifetime_in_seconds = 120
    secret_encoded      = true
    alg                 = "RS256"
  }

  custom_login_page_on = "true"
 
  addons = {
    samlp = {
      audience = "${var.jenkins_url}/securityRealm/finishLogin",
      recipient = "${var.jenkins_url}/securityRealm/finishLogin"
    }
  }
}

resource "auth0_rule" "jenkins" {
  count = "${var.application_type == "jenkins" ? 1 : 0}"
  name = "${var.application_name}"
  script = <<EOF
function (user, context, callback) {
  var _ = require('lodash');
  var EXTENSION_URL = "${var.extension_url}";

  var audience = '';
  audience = audience || (context.request && context.request.query && context.request.query.audience);
  if (audience === 'urn:auth0-authz-api') {
    return callback(new UnauthorizedError('no_end_users'));
  }

  audience = audience || (context.request && context.request.body && context.request.body.audience);
  if (audience === 'urn:auth0-authz-api') {
    return callback(new UnauthorizedError('no_end_users'));
  }

  getPolicy(user, context, function(err, res, data) {
    if (err) {
      console.log('Error from Authorization Extension:', err);
      return callback(new UnauthorizedError('Authorization Extension: ' + err.message));
    }

    if (res.statusCode !== 200) {
      console.log('Error from Authorization Extension:', res.body || res.statusCode);
      return callback(
        new UnauthorizedError('Authorization Extension: ' + ((res.body && (res.body.message || res.body) || res.statusCode)))
      );
    }

    if(context.clientID === "${auth0_client.jenkins.id}"){
       // Update the user object.
       user.groups = data.groups;
       var jenkins_groups = user.groups.filter(group => group.match('${var.application_name}') !== null);
       jenkins_groups.forEach((g,i)=> {jenkins_groups[i] = jenkins_groups[i].replace('${var.application_name}_','');});
       user.groups = jenkins_groups;
    }
   
    return callback(null, user, context);
  });
  
  // Convert groups to array
  function parseGroups(data) {
    if (typeof data === 'string') {
      // split groups represented as string by spaces and/or comma
      return data.replace(/,/g, ' ').replace(/\s+/g, ' ').split(' ');
    }
    return data;
  }

  // Get the policy for the user.
  function getPolicy(user, context, cb) {
    request.post({
      url: EXTENSION_URL + "/api/users/" + user.user_id + "/policy/" + context.clientID,
      headers: {
        "x-api-key": configuration.AUTHZ_EXT_API_KEY
      },
      json: {
        connectionName: context.connection || user.identities[0].connection,
        groups: parseGroups(user.groups)
      },
      timeout: 5000
    }, cb);
  }
}
EOF
  enabled = true
}