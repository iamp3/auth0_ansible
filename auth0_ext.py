#!/usr/bin/env python
import requests
import json
import re

def main():
    module = AnsibleModule(
        argument_spec = dict(
            token=dict(type='str', required=True),
            domain=dict(type='str', required=True),
            state=dict(required=False, choises=['present', 'absent'], default='present'),
            groups=dict(type='str', required=True),
            members=dict(type='list', required=True, default=[])
        )
    )

    # if module.params['state'] == 'present':
    #     create_group(module)
    # elif module.params['state'] == 'absent':
    #     delete_group(module)

        m_payload = module.params['members']
        data = json.loads(m_payload)
        print data[]

# def create_group(module):
#     g_url = module.params['domain'] + "/groups"
#     payload = ('{ "name" : "' + str(module.params['groups']) + '", "description": "' + str(module.params['groups']) +'"}')

#     headers = {
#         'Content-type': 'application/json',
#         'authorization': module.params['token']
#     }   
    
#     rc = requests.request("POST", g_url, data=payload, headers=headers)
#     response = rc.json()
    
#         m_payload = module.params['members']
#         data = json.loads(m_payload)
#         print data[]

#     if rc.status_code == 200:
#         m_payload = module.params['members']

#         m_url = module.params['domain'] + str("/groups/" + response['_id']) + "/members"
#         print(m_payload)
#         rm = requests.request("PATCH", m_url, data=m_payload, headers=headers)
#     else:
#         return module.exit_json(changed=False)

#     return module.exit_json(msg=rm.json())

from ansible.module_utils.basic import *
from ansible.module_utils.urls import *
main()