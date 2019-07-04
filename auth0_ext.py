#!/usr/bin/env python
import requests
import json

def main():
    module = AnsibleModule(
        argument_spec = dict(
            token=dict(type='str', required=True),
            domain=dict(type='str', required=True),
            action=dict(required=True, choises=['create_group', 'add_members']),
            description=dict(type='str', required=True),
            group=dict(type='str', required=True),
            members=dict(required=False, type='list', default=[])
        )
    )

    if module.params['action'] == 'create_group':
        create_group(module)
    elif module.params['action'] == 'add_members':
        add_members(module)

def create_group(module):      
    url = module.params['domain'] + "/groups"
    payload = ('{ "name" : "' + str(module.params['group']) + '", "description": "' + str(module.params['description']) +'"}')

    headers = {
        'Content-type': 'application/json',
        'authorization': module.params['token']
    }    
    
    r = requests.request("POST", url, data=payload, headers=headers)    

    if r.status_code == 200:
        return module.exit_json(changed=False, meta=r.json())
    else:
        return module.fail_json(msg=r.json())

def add_members(module):      
    url = module.params['domain'] + "/groups" + "id_" + "/members"
    print(module.params['members'])
    payload = ('['+ str(module.params['members']) +']')

    headers = {
        'Content-type': 'application/json',
        'authorization': module.params['token']
    }    
    
    r = requests.request("PATCH", url, data=payload, headers=headers)    

    return module.fail_json(msg=r.json())

from ansible.module_utils.basic import *
from ansible.module_utils.urls import *
main()