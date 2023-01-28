#!/usr/bin/env bash
# set colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m'

#default parameters
TF_WORKSPACE='stage'
HOME_DEPLOY='yes' # 'yes' or 'no'
HOME_VM1_IP='192.168.8.50'
HOME_VM2_IP='192.168.8.51'
HOME_VM3_IP='192.168.8.52'

if [ "$1" == "preapply" ]
then  
    if [ "${HOME_DEPLOY}" == no ]
    then
        source 02-yc-export/yc_work.sh apply
        source 02-yc-export/yc_work.sh s3create
        printf "${BLUE}--- Terraform create WS and select...${NC}\n"
        terraform workspace new ${TF_WORKSPACE}
    else 
        printf "${YELLOW}--- NO need to preapply...${NC}\n" 
    fi
fi

# if [ "$1" == "export" ]
# then  
#     source 02-yc-export/yc_work.sh export
# fi

if [ "$1" == "apply" ]
then  
    if [ "${HOME_DEPLOY}" == no ]
    then
        printf "${BLUE}--- Terraform INIT and APPLY ...${NC}\n"
        terraform -chdir=15-terraform  workspace select ${TF_WORKSPACE}
        terraform -chdir=15-terraform  init
        terraform -chdir=15-terraform  apply -auto-approve  
        vm_ip1=$(terraform -chdir=15-terraform output external_ip_address_vm_1)
        vm_ip2=$(terraform -chdir=15-terraform output external_ip_address_vm_2)
        vm_ip3=$(terraform -chdir=15-terraform output external_ip_address_vm_3)
    else
        vm_ip1=${HOME_VM1_IP}
        vm_ip2=${HOME_VM2_IP}
        vm_ip3=${HOME_VM3_IP}
    fi
    printf "${BLUE}--- VM adresses ...${NC}\n"
    printf "vm1-master: ${GREEN}$vm_ip1"
    printf "vm2-node01: ${GREEN}$vm_ip2"
    printf "vm3-node02: ${GREEN}$vm_ip3"
fi

if [ "$1" == "destroy" ]
then  
   if [ "${HOME_DEPLOY}" == no ]
    then
        printf "${BLUE}--- Terraform ${RED}DESTROY${BLUE} ...${NC}\n"
        terraform -chdir=15-terraform  workspace select ${TF_WORKSPACE}
        terraform -chdir=15-terraform destroy -auto-approve
        02-yc-export/yc_work.sh delete
    else 
        printf "${YELLOW}--- NO need to destroy...${NC}\n" 
    fi
fi

if [ "$1" == "play" ]
then 
    if [ "${HOME_DEPLOY}" == no ]
    then
        terraform -chdir=15-terraform  workspace select ${TF_WORKSPACE}
        vm_ip1=$(terraform -chdir=15-terraform  output external_ip_address_vm_1)
        vm_ip2=$(terraform -chdir=15-terraform  output external_ip_address_vm_2)
        vm_ip3=$(terraform -chdir=15-terraform  output external_ip_address_vm_3)
    else
        vm_ip1=${HOME_VM1_IP}
        vm_ip2=${HOME_VM2_IP}
        vm_ip3=${HOME_VM3_IP}
    fi
    printf "${BLUE}--- Starting ansible-playbook PLAY ...${NC}\n"
    printf "vm1-master: ${GREEN}$vm_ip1${NC}\n"
    printf "vm2-node01: ${GREEN}$vm_ip2${NC}\n"
    printf "vm3-node02: ${GREEN}$vm_ip3${NC}\n"
    #ansible-playbook -i playbook/inventory/prod.yml playbook/site.yml -e vmip1=$vm_ip1 -e vmip2=$vm_ip2 -e vmip3=$vm_ip3 --diff && echo "--- All ok. Check the service! " 
fi

if [ "$1" == "check" ]
then  
    if [ "${HOME_DEPLOY}" == no ]
    then
        terraform -chdir=15-terraform  workspace select ${TF_WORKSPACE}
        vm_ip1=$(terraform -chdir=15-terraform output external_ip_address_vm_1)
        vm_ip2=$(terraform -chdir=15-terraform output external_ip_address_vm_2)
        vm_ip3=$(terraform -chdir=15-terraform output external_ip_address_vm_3)
    else
        vm_ip1=${HOME_VM1_IP}
        vm_ip2=${HOME_VM2_IP}
        vm_ip3=${HOME_VM3_IP}
    fi
    printf "${BLUE}--- Starting ansible-playbook PLAY (check mode)...${NC}\n"
    printf "vm1-master: ${GREEN}$vm_ip1${NC}\n"
    printf "vm2-node01: ${GREEN}$vm_ip2${NC}\n"
    printf "vm3-node02: ${GREEN}$vm_ip3${NC}\n"
    #ansible-playbook -i playbook/inventory/prod.yml playbook/site.yml -e vmip1=$vm_ip1 -e vmip2=$vm_ip2 -e vmip3=$vm_ip3 --check
fi

if [ "$1" == "show" ]
then  
    if [ "${HOME_DEPLOY}" == no ]
        then
        terraform -chdir=15-terraform  workspace select ${TF_WORKSPACE}
        vm_ip1=$(terraform -chdir=15-terraform  output external_ip_address_vm_1)
        vm_ip2=$(terraform -chdir=15-terraform  output external_ip_address_vm_2)
        vm_ip3=$(terraform -chdir=15-terraform  output external_ip_address_vm_3)
        02-yc-export/yc_work.sh show
    else
        vm_ip1=${HOME_VM1_IP}
        vm_ip2=${HOME_VM2_IP}
        vm_ip3=${HOME_VM3_IP}
    fi
    printf "${BLUE}--- VM adresses ...${NC}\n"
    printf "vm1-master: ${GREEN}$vm_ip1${NC}\n"
    printf "vm2-node01: ${GREEN}$vm_ip2${NC}\n"
    printf "vm3-node02: ${GREEN}$vm_ip3${NC}\n"
fi