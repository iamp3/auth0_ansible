#!/usr/bin/env python
import requests
import json

def main():
    module = AnsibleModule(
        argument_spec = dict(
            token=dict(type='str', required=True),
            domain=dict(type='str', required=True),
            state=dict(required=False, choises=['present', 'absent'], default='present'),
            group=dict(type='str', required=True),
            description=dict(type='str', required=True),
#            members=dict(required=False, type='dict', default={})
        )
    )

    if module.params['state'] == 'present':
        create_group(module)
    elif module.params['state'] == 'absent':
        delete_group(module)

def create_group(module):      
    url = module.params['domain'] + "/groups"
    payload = ('{ "name" : "' + str(module.params['group']) + '", "description": "' + str(module.params['description']) +'"}')

    headers = {
        'Content-type': 'application/json',
        'authorization': module.params['token']
    }    
    
    response = requests.request("POST", url, data=payload, headers=headers)
    
    module.fail_json(msg='You requested this to fail')
    module.exit_json(msg='You requested this to success')


from ansible.module_utils.basic import *
from ansible.module_utils.urls import *
main()