#!/usr/bin/env bash
# set colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
NC='\033[0m'

# predifoned in "yc init"
YC_TOKEN=$(yc config get token)
YC_CLOUD_ID=$(yc config get cloud-id)
YC_FOLDER_ID=$(yc config get folder-id)

#default parameters
YC_SERVICE_ACCOUNT='tf-sa'
YC_SA_ROLE='editor'
YC_S3_BUCKETNAME='tf-bucket'

if [ "$1" == "apply" ]
then  
   #Creating Service Account
  printf "${BLUE}--- Creating Service Account${NC}\n"
  yc iam service-account create ${YC_SERVICE_ACCOUNT} \
    --folder-id ${YC_FOLDER_ID}

  #Assigning role to SA
  printf "${BLUE}--- Assigning role to SA...${NC}\n"
  yc resource-manager folder add-access-binding ${YC_FOLDER_ID} \
    --service-account-name ${YC_SERVICE_ACCOUNT} \
    --role ${YC_SA_ROLE} \
    --folder-id ${YC_FOLDER_ID}

  #Creating IAM key for SA
  printf "${BLUE}--- Creating IAM key for SA...${NC}\n"
  yc iam key create --service-account-name ${YC_SERVICE_ACCOUNT} \
    --folder-id ${YC_FOLDER_ID} \
    --output key.json

  #Creating IAM access-key for S3
  printf "${BLUE}--- Creating IAM access-key for S3...${NC}\n"
  yc iam access-key create --service-account-name ${YC_SERVICE_ACCOUNT} \
    --folder-id  ${YC_FOLDER_ID} 

 #set env
  export TF_VAR_YC_TOKEN=$YC_TOKEN
  export TF_VAR_YC_CLOUD_ID=$YC_CLOUD_ID
  export TF_VAR_YC_FOLDER_ID=$YC_FOLDER_ID
  export TF_VAR_YC_SA_PUBLICKEYID=$(yc iam key list  --service-account-name $YC_SERVICE_ACCOUNT --format json | jq -r '.[0].id')
  export TF_VAR_YC_SA_PUBLICKEY=$(yc iam key list  --service-account-name $YC_SERVICE_ACCOUNT --format json | jq -r '.[0].public_key')
  export TF_VAR_YC_SA_ACCESSKEY=$(yc iam access-key list --service-account-name  $YC_SERVICE_ACCOUNT --format json | jq -r '.[0].key_id')
  export TF_VAR_YC_SA_SECRETKEY=$(yc iam access-key list --service-account-name  $YC_SERVICE_ACCOUNT --format json | jq -r '.[0].key_id')
fi

if [ "$1" == "show" ]
then  
printf "TOKEN: ${GREEN}$YC_TOKEN${NC}\n"
printf "CLOUD_ID: ${GREEN}$YC_CLOUD_ID${NC}\n"
printf "FOLDER_ID: ${GREEN}$YC_FOLDER_ID${NC}\n"
printf "SA: ${GREEN}$YC_SERVICE_ACCOUNT${NC}\n"
printf "SA_ROLE: ${GREEN}$YC_SA_ROLE${NC}\n"
printf "SA_ID: ${GREEN}$(yc iam service-account get tf-sa  --format json | jq -r .id)${NC}\n"
printf "SA_PUBLICKEY: ${GREEN}$(yc iam key list  --service-account-name $YC_SERVICE_ACCOUNT --format json | jq -r '.[0].public_key')${NC}\n"
printf "SA_ACCESSKEY: ${GREEN}$(yc iam access-key list --service-account-name  $YC_SERVICE_ACCOUNT --format json | jq -r '.[0].key_id')${NC}\n"
fi

if [ "$1" == "export" ]
then  
  #set env
  printf "${BLUE}--- ENV exporting...${NC}\n"
  export TF_VAR_YC_TOKEN=$YC_TOKEN
  export TF_VAR_YC_CLOUD_ID=$YC_CLOUD_ID
  export TF_VAR_YC_FOLDER_ID=$YC_FOLDER_ID
  export TF_VAR_YC_SA_PUBLICKEYID=$(yc iam key list  --service-account-name $YC_SERVICE_ACCOUNT --format json | jq -r '.[0].id')
  export TF_VAR_YC_SA_PUBLICKEY=$(yc iam key list  --service-account-name $YC_SERVICE_ACCOUNT --format json | jq -r '.[0].public_key')
  export TF_VAR_YC_SA_ACCESSKEY=$(yc iam access-key list --service-account-name $YC_SERVICE_ACCOUNT --format json | jq -r '.[0].key_id')
  export TF_VAR_YC_SA_SECRETKEY=$(yc iam access-key list --service-account-name  $YC_SERVICE_ACCOUNT --format json | jq -r '.[0].key_id')
fi


if [ "$1" == "s3create" ]
then  
  printf "{$BLUE}--- Creating S3 in YC...${NC}\n"
  yc s3 create --service-account-name ${YC_SERVICE_ACCOUNT} \
    --folder-id  ${YC_FOLDER_ID} \
    --s3-name ${YC_S3_BUCKETNAME}
fi
