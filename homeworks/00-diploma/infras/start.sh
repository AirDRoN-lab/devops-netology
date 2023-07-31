#!/usr/bin/env bash
# set colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m'

#default parameters
TF_WORKSPACE='stage'


if [ "$1" == "init" ]
then  
    source 02-yc-export/yc_work.sh init
fi

if [ "$1" == "sas3-create" ]
then  
    source 02-yc-export/yc_work.sh sa-create
    source 02-yc-export/yc_work.sh s3-create
fi

if [ "$1" == "infra-create" ]
then  
    printf "${BLUE}--- Terraform INIT and APPLY ...${NC}\n"
    terraform -chdir=15-terraform  init
    terraform -chdir=15-terraform  workspace new ${TF_WORKSPACE}
    terraform -chdir=15-terraform  workspace select ${TF_WORKSPACE}
    terraform -chdir=15-terraform  apply -auto-approve  
    vm_ip1=$(terraform -chdir=15-terraform output external_ip_address_vm_1 | tr -d \")
    vm_ip2=$(terraform -chdir=15-terraform output external_ip_address_vm_2 | tr -d \")
    vm_ip3=$(terraform -chdir=15-terraform output external_ip_address_vm_3 | tr -d \")
    vm_ip1int=$(terraform -chdir=15-terraform output internal_ip_address_vm_1 | tr -d \")
    vm_ip2int=$(terraform -chdir=15-terraform output internal_ip_address_vm_2 | tr -d \")
    vm_ip3int=$(terraform -chdir=15-terraform output internal_ip_address_vm_3 | tr -d \")
    printf "${BLUE}--- VM adresses ...${NC}\n"
    printf "vm1-master: ${GREEN}$vm_ip1 $vm_ip1int\n"
    printf "vm2-node01: ${GREEN}$vm_ip2 $vm_ip2int\n"
    printf "vm3-node02: ${GREEN}$vm_ip3 $vm_ip3int\n"  
    printf "${BLUE}--- Export VM_ip to ENV ...${NC}\n"
    export vm_ip1=$vm_ip1
    export vm_ip2=$vm_ip2
    export vm_ip3=$vm_ip3
    export vm_ip1int=$vm_ip1int
    export vm_ip2int=$vm_ip2int
    export vm_ip3int=$vm_ip3int
fi

if [ "$1" == "all-destroy" ]
then  
    printf "${BLUE}--- Terraform ${RED}DESTROY${BLUE} ...${NC}\n"
    terraform -chdir=15-terraform init
    terraform -chdir=15-terraform workspace list
    terraform -chdir=15-terraform workspace select ${TF_WORKSPACE}
    terraform -chdir=15-terraform destroy -auto-approve
    source 02-yc-export/yc_work.sh all-delete
fi

if [ "$1" == "kube-play" ]
then
    printf "${BLUE}--- Starting ansible-playbook PLAY ...${NC}\n"
    printf "vm1-master: ${GREEN}$vm_ip1${NC}\n"
    printf "vm2-node01: ${GREEN}$vm_ip2${NC}\n"
    printf "vm3-node02: ${GREEN}$vm_ip3${NC}\n"
    printf "vm1-master-ext: ${GREEN}$vm_ip1${NC}\n"
    ansible-playbook -i 20-kube/inventory/kuber/hosts.yaml 20-kube/cluster.yml -b -v -e vmip1=$vm_ip1 -e vmip2=$vm_ip2 -e vmip3=$vm_ip3 -e vmip1ext=$vm_ip1 --diff && printf "${BLUE}--- All ok! Check kuber...${NC}\n"
fi

if [ "$1" == "kube-playcheck" ]
then
    printf "${BLUE}--- Starting ansible-playbook PLAY ...${NC}\n"
    printf "vm1-master: ${GREEN}$vm_ip1${NC}\n"
    printf "vm2-node01: ${GREEN}$vm_ip2${NC}\n"
    printf "vm3-node02: ${GREEN}$vm_ip3${NC}\n"
    printf "vm1-master-ext: ${GREEN}$vm_ip1${NC}\n"
    ansible-playbook -i 20-kube/inventory/kuber/hosts.yaml 20-kube/cluster.yml -b -v -e vmip1=$vm_ip1 -e vmip2=$vm_ip2 -e vmip3=$vm_ip3 -e vmip1ext=$vm_ip1 --check && printf "${BLUE}--- All ok! Check kuber...${NC}\n"
fi

if [ "$1" == "env-export" ]
then 
    terraform -chdir=15-terraform  workspace select ${TF_WORKSPACE}
    vm_ip1=$(terraform -chdir=15-terraform  output external_ip_address_vm_1 | tr -d \")
    vm_ip2=$(terraform -chdir=15-terraform  output external_ip_address_vm_2 | tr -d \")
    vm_ip3=$(terraform -chdir=15-terraform  output external_ip_address_vm_3 | tr -d \")
    vm_ip1int=$(terraform -chdir=15-terraform  output internal_ip_address_vm_1 | tr -d \")
    vm_ip2int=$(terraform -chdir=15-terraform  output internal_ip_address_vm_2 | tr -d \")
    vm_ip3int=$(terraform -chdir=15-terraform  output internal_ip_address_vm_3 | tr -d \")
    printf "${BLUE}--- VM adresses [ext_IP] [int_IP] ...${NC}\n"
    printf "vm1-master: ${GREEN}$vm_ip1 $vm_ip1int ${NC}\n"
    printf "vm2-node01: ${GREEN}$vm_ip2 $vm_ip2int ${NC}\n"
    printf "vm3-node02: ${GREEN}$vm_ip3 $vm_ip3int ${NC}\n"
    printf "${BLUE}--- Export VM_ip to ENV ...${NC}\n"
    export vm_ip1=$vm_ip1
    export vm_ip2=$vm_ip2
    export vm_ip3=$vm_ip3
    export vm_ip1ext=$vm_ip1
    export vm_ip1int=$vm_ip1int
    export vm_ip2int=$vm_ip2int
    export vm_ip3int=$vm_ip3int
    source 02-yc-export/yc_work.sh env-export
fi

if [ "$1" == "all-show" ]
then  
    terraform -chdir=15-terraform  workspace select ${TF_WORKSPACE}
    vm_ip1=$(terraform -chdir=15-terraform  output external_ip_address_vm_1 | tr -d \")
    vm_ip2=$(terraform -chdir=15-terraform  output external_ip_address_vm_2 | tr -d \")
    vm_ip3=$(terraform -chdir=15-terraform  output external_ip_address_vm_3 | tr -d \")
    02-yc-export/yc_work.sh all-show
    printf "${BLUE}--- VM adresses [ext_IP] [int_IP] ...${NC}\n"
    printf "vm1-master: ${GREEN}$vm_ip1 $vm_ip1int ${NC}\n"
    printf "vm2-node01: ${GREEN}$vm_ip2 $vm_ip2int ${NC}\n"
    printf "vm3-node02: ${GREEN}$vm_ip3 $vm_ip3int ${NC}\n"
fi