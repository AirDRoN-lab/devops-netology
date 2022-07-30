# Ansible Collection - airdron.operwfile

## DESCRIPTION

Test collection. Operations with file.
```
module: wfile
short_description: This is test module to write content to file.
version_added: "1.0.0"
description: This is test module to write content to file. Module has two options: "path" and "content"

options:
    path:
        description: Path to FILE
        required: true
        type: str
    content:
        description: FILE content
        required: false
        type: str

author:
    - Dmitry G
```

## EXAMPLES:
```
- name: WRITE a FILE
  airdron.operwfile.wfile:
    path: "~/test.txt" 
    content: "Hello World!"

- name: Test failure of the module
  my_namespace.my_collection.my_test:
    content: fail me
```

## RETURN
```
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'Ok, writing to file'
```