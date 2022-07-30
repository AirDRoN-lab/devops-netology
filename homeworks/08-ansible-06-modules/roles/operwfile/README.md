Role Name - operwfile
=========

Requirements
------------

No-Requirements

Role Variables
--------------

There are default variables:
```
path: "~/test.txt" 
content: "testcontent"
```

Dependencies
------------

No dependecies

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yml
- name: TEST the module
  hosts: localhost
  collections:
    - airdron.operwfile
  roles:
    - operwfile
```

License
-------

BSD

Author Information
------------------

AirDRoN-LAB
