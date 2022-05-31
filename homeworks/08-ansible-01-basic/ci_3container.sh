#!/usr/bin/env bash

run_fedora=$(docker ps -a --format "{{.Names}}" | grep fedora | wc -l)
run_centos=$(docker ps -a --format "{{.Names}}" | grep centos7 | wc -l)
run_ubuntu=$(docker ps -a --format "{{.Names}}" | grep ubuntu | wc -l)

if [ "$run_fedora" != 0 ]
then  
	
	echo "--- 'fedora' is present in docker ps -a. Trying to remove..."
        docker stop fedora && docker rm fedora
fi

if [ "$run_centos" != 0 ]
then 
        echo "--- 'centos' is present in docker ps -a. Trying to remove..."
	docker stop centos7 && docker rm centos7
fi

if [ "$run_ubuntu" != 0 ]
then 
        echo "--- 'ubuntu' is present in docker ps -a. Trying to remove..."
	docker stop ubuntu && docker rm ubuntu
fi

echo "--- Starting docker containers..."
docker run -d --name fedora pycontribs/fedora sleep 6000
docker run -d --name centos7 pycontribs/centos:7 sleep 6000
docker run -d --name ubuntu pycontribs/ubuntu sleep 6000
echo "--- Starting ansible-playbook..."
ansible-playbook -i inventory/prod.yml --vault-password-file=secret site.yml && echo "--- All ok. Stopping containers..." && docker stop fedora ubuntu centos7
