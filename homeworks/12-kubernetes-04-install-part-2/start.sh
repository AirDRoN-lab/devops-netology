#!/usr/bin/env bash

if [ "$1" == "apply" ]
then  
    echo "--- Starting Terraform ..."
    terraform -chdir=terraform init
    terraform -chdir=terraform apply -auto-approve  
    vm_ip1=$(terraform -chdir=terraform output external_ip_address_vm_1)
    vm_ip2=$(terraform -chdir=terraform output external_ip_address_vm_2)
    vm_ip3=$(terraform -chdir=terraform output external_ip_address_vm_3)
    vm_ip4=$(terraform -chdir=terraform output external_ip_address_vm_4)
    vm_ip5=$(terraform -chdir=terraform output external_ip_address_vm_5)
  
    echo "--- Terraform Output ..."
    echo "$vm_ip1"
    echo "$vm_ip2"
    echo "$vm_ip3"
    echo "$vm_ip4"
    echo "$vm_ip5"
fi

if [ "$1" == "destroy" ]
then  
    echo "--- Starting Terraform ..."
    terraform -chdir=terraform destroy -auto-approve
fi

# if [ "$1" == "play" ]
# then  
#     vm_ip1=$(terraform -chdir=terraform output external_ip_address_vm_1)
#     vm_ip2=$(terraform -chdir=terraform output external_ip_address_vm_2)
#     echo "--- Using IP adresses ..."
#     echo "$vm_ip1"
#     echo "$vm_ip2"
#     ansible-playbook -i infrastructure/inventory/cicd/hosts.yml infrastructure/site.yml -e vmip1=$vm_ip1 -e vmip2=$vm_ip2  --diff && echo "--- All ok. Check the service! " 
# fi

# if [ "$1" == "check" ]
# then  
#     vm_ip1=$(terraform -chdir=terraform output external_ip_address_vm_1)
#     vm_ip2=$(terraform -chdir=terraform output external_ip_address_vm_2)
#     echo "--- Using IP adresses ..."
#     echo "$vm_ip1"
#     echo "$vm_ip2"
#     ansible-playbook -i infrastructure/inventory/cicd/hosts.yml infrastructure/site.yml  -e vmip1=$vm_ip1 -e vmip2=$vm_ip2 --check
# fi

if [ "$1" == "showip" ]
then  
    vm_ip1=$(terraform -chdir=terraform output external_ip_address_vm_1)
    vm_ip2=$(terraform -chdir=terraform output external_ip_address_vm_2)
    vm_ip3=$(terraform -chdir=terraform output external_ip_address_vm_3)
    vm_ip4=$(terraform -chdir=terraform output external_ip_address_vm_4)
    vm_ip5=$(terraform -chdir=terraform output external_ip_address_vm_5)
    echo "--- Using IP adresses ..."
    echo "$vm_ip1"
    echo "$vm_ip2"
    echo "$vm_ip3"
    echo "$vm_ip4"
    echo "$vm_ip5"
fi
