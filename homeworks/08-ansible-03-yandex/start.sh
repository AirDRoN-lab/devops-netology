#!/usr/bin/env bash

if [ "$1" == "apply" ]
then  
    echo "--- Starting Terraform ..."
    terraform -chdir=terraform init
    terraform -chdir=terraform apply -auto-approve  
    vm_ip1=$(terraform -chdir=terraform output external_ip_address_vm_1)
    vm_ip2=$(terraform -chdir=terraform output external_ip_address_vm_2)
    vm_ip3=$(terraform -chdir=terraform output external_ip_address_vm_3)

    echo "--- Terraform Output ..."
    echo "$vm_ip1"
    echo "$vm_ip2"
    echo "$vm_ip3"
fi

if [ "$1" == "destroy" ]
then  
    echo "--- Starting Terraform ..."
    terraform -chdir=terraform destroy -auto-approve
fi

if [ "$1" == "play" ]
then  
    vm_ip1=$(terraform -chdir=terraform output external_ip_address_vm_1)
    vm_ip2=$(terraform -chdir=terraform output external_ip_address_vm_2)
    vm_ip3=$(terraform -chdir=terraform output external_ip_address_vm_3)
    echo "--- Using IP adresses ..."
    echo "$vm_ip1"
    echo "$vm_ip2"
    echo "$vm_ip3"
    ansible-playbook -i playbook/inventory/prod.yml playbook/site.yml -e vmip1=$vm_ip1 -e vmip2=$vm_ip2 -e vmip3=$vm_ip3 --diff && echo "--- All ok. Check the service! " 
fi

if [ "$1" == "check" ]
then  
    vm_ip1=$(terraform -chdir=terraform output external_ip_address_vm_1)
    vm_ip2=$(terraform -chdir=terraform output external_ip_address_vm_2)
    vm_ip3=$(terraform -chdir=terraform output external_ip_address_vm_3)
    echo "--- Using IP adresses ..."
    echo "$vm_ip1"
    echo "$vm_ip2"
    echo "$vm_ip3"
    ansible-playbook -i playbook/inventory/prod.yml playbook/site.yml -e vmip1=$vm_ip1 -e vmip2=$vm_ip2 -e vmip3=$vm_ip3 --check
fi

if [ "$1" == "showip" ]
then  
    vm_ip1=$(terraform -chdir=terraform output external_ip_address_vm_1)
    vm_ip2=$(terraform -chdir=terraform output external_ip_address_vm_2)
    vm_ip3=$(terraform -chdir=terraform output external_ip_address_vm_3)
    echo "--- Using IP adresses ..."
    echo "$vm_ip1"
    echo "$vm_ip2"
    echo "$vm_ip3"
fi