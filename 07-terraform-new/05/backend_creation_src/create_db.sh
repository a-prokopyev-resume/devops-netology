#!/bin/bash
#set -x;

DB_ID=$(yc ydb database list | grep terraform | awk '{ print $2 }');
yc ydb database get $DB_ID > /tmp/db_info.yml;
GRPC_API=$(cat /tmp/db_info.yml | yq -r .endpoint /tmp/db_info.yml);
DocAPI=$(cat /tmp/db_info.yml | yq -r .document_api_endpoint /tmp/db_info.yml);
Database=$(echo $DocAPI | grep -P '/ru-central1/.*' -o);

yc iam create-token > /tmp/iam_12h_token;

yql()
{
	QueryText="$1";
	proxychains ydb --database $Database --endpoint $GRPC_API --iam-token-file /tmp/iam_12h_token yql --script "$QueryText";
}

#yql "CREATE TABLE terraform_locks (LockID String, PRIMARY KEY (LockID))";
yql "select count(*) from terraform_locks";
yql "select * from terraform_locks";

#aws dynamodb create-table \
#  --table-name terraform_locks \
#  --attribute-definitions AttributeName=LockID,AttributeType=S \
#  --key-schema AttributeName=LockID,KeyType=HASH \
#  --endpoint $DocAPI;

# Wiping temporary token and yml
echo > /tmp/iam_12h_token; 
echo > /tmp/db_info.yml;
