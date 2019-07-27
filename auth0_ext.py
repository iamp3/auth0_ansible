#!/usr/bin/env python
import requests
import json

def main():
    module = AnsibleModule(
        argument_spec = dict(
            client_id=dict(type='str', required=True),
            client_secret=dict(type='str', required=True),
            domain_main=dict(type='str', required=True),
            domain_ext=dict(type='str', required=True),
            state=dict(required=False, choises=['present', 'absent'], default='present'),
            groups=dict(type='str', required=True),
            members=dict(type='list', required=True)
        )
    )

    if module.params['state'] == 'present':
       create_group(module)
    elif module.params['state'] == 'absent':
        delete_members(module)

def get_token(module):
    
    global bearer_token, users_ids
    token_url = module.params['domain_main'] + "/oauth/token"
    payload = ('{ "client_id":"' + str(module.params['client_id']) + '","client_secret":"' + str(module.params['client_secret']) + '","audience":"urn:auth0-authz-api","grant_type":"client_credentials" }')

    headers = {
        'Content-type': 'application/json'
    }   
    
    token_r = requests.request("POST", token_url, data=payload, headers=headers)
    token_response = token_r.json()
    bearer_token = (token_response["access_token"])

### Users get
    users_url = module.params['domain_ext'] + "/users"
    headers_users = {
        'Content-type': 'application/json',
        'authorization': 'Bearer ' + bearer_token
    }  

    users_r = requests.request("GET", users_url, headers=headers_users)
    users_response = users_r.json()
    users_ids = [member['user_id'] for member in users_response['users'] if member['email'] in module.params['members']]

    return(bearer_token, users_ids)

def create_group(module):
    get_token(module)

    g_url = module.params['domain_ext'] + "/groups"
    payload = ('{ "name":"' + str(module.params['groups']) + '", "description":"' + str(module.params['groups']) +'"}')

    headers = {
        'Content-type': 'application/json',
        'authorization': 'Bearer ' + bearer_token
    }   

    r = requests.request("POST", g_url, data=payload, headers=headers)
    response = r.json()

    m_payload = str(users_ids)
    m_payload = m_payload.replace("'", '"')

    if r.status_code == 200:
        m_url = module.params['domain_ext'] + str("/groups/" + response['_id']) + "/members"
        rm = requests.request("PATCH", m_url, data=m_payload, headers=headers)
        return module.exit_json(changed=False)
    else:
        if r.status_code == 400:
            rg = requests.request("GET", g_url, headers=headers)
            response_g = rg.json()
            g_id = next(group["_id"] for group in response_g["groups"] if group["description"] == module.params['groups'])
            cg_url = g_url + str("/" + g_id) + "/members"
            rmg = requests.request("PATCH", cg_url, data=m_payload, headers=headers)
            return module.exit_json(changed=False)

    return module.exit_json(msg=response)

def delete_members(module):
    get_token(module)
    
    headers = {
        'Content-type': 'application/json',
        'authorization': 'Bearer ' + bearer_token
    }

    groups_url = module.params['domain_ext'] + "/groups"
    rg = requests.request("GET", groups_url, headers=headers)
    response_g = rg.json()
    g_id = next(group["_id"] for group in response_g["groups"] if group["description"] == module.params['groups'])
    dg_url = groups_url + str("/" + g_id) + "/members"
    dmg_payload = str(users_ids)
    dmg_payload = dmg_payload.replace("'", '"')
    dmg = requests.request("DELETE", dg_url, data=dmg_payload, headers=headers)
    return module.exit_json(changed=False)
    

from ansible.module_utils.basic import *
from ansible.module_utils.urls import *
main()