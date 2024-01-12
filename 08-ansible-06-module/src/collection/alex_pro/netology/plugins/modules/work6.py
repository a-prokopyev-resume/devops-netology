#!/usr/bin/python

# Copyright: (c) 2024, Alexander B. Prokopyev <a.prokopyev.resume at gmail dot com>
# AGPLv3 
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: alex_pro.netology.work6

short_description: Writes supplied text message to a specified file

version_added: "1.0.0"

description: Alex Pro Netology 08-ansible-06-module lesson

options:
    name:
        path: path to the file which is created
        required: true
        type: str
        content: Message written to the file
        required: true
        type: str

author:
    - Alexander Prokopyev (a.prokopyev.resume at gmail dot com)
'''

EXAMPLES = r'''
# Pass in a message
- name: Write file
  alex_pro.netology.work6:
    path: /tmp/hello.txt
    content: Hello World!
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
message:
    description: Error message
    type: str
    returned: always
    sample: 'Success'
'''
    
import json
from ansible.module_utils.basic import AnsibleModule
import sys
def main():
    module = AnsibleModule(
        argument_spec = dict(
            path = dict(required=True, type='str'),
            content  = dict(required=True, type='str'),
        )
    )
    
    path = module.params['path']
    content = module.params['content']


    data = dict(
        output=" Required content has been successfully written to the required file.",
    )
    try:
        file = open(path,"w")
        file.write(content)
        module.exit_json(changed=True, success=data, msg=data)
    except Exception as e:
        module.fail_json(msg='An error occurred: '+str(e.args))


if __name__ == '__main__':
    main()
    