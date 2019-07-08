#!/usr/bin/env python
import requests
import json

def main():
    module = AnsibleModule(
        argument_spec = dict(
            token=dict(type='str', required=True),
            domain=dict(type='str', required=True),
            state=dict(required=False, choises=['present', 'absent'], default='present'),
            groups=dict(type='str', required=True),
            members=dict(type='list', required=True)
        )
    )

    if module.params['state'] == 'present':
        create_group(module)
    elif module.params['state'] == 'absent':
        delete_group(module)

def create_group(module):
    g_url = module.params['domain'] + "/groups"
    payload = ('{ "name" : "' + str(module.params['groups']) + '", "description": "' + str(module.params['groups']) +'"}')

    headers = {
        'Content-type': 'application/json',
        'authorization': module.params['token']
    }   
    
    r = requests.request("POST", g_url, data=payload, headers=headers)
    response = r.json()
    
    m_payload = str(module.params['members'])
    m_payload = m_payload.replace("'", '"')

    if r.status_code == 200:
        m_url = module.params['domain'] + str("/groups/" + response['_id']) + "/members"
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

    return module.exit_json(msg=r.json())

from ansible.module_utils.basic import *
from ansible.module_utils.urls import *
main()