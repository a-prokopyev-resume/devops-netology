#!/usr/bin/env -vS bash -li

#=============================================== The Beginning of the Copyright Notice ===================================================
# The AUTHOR of this file and the owner of all exclusive rights in this file is Alexander Borisovich Prokopyev
# born on December 20, 1977 resident of the city of Kurgan, Russia;
# Series and Russian passport number of the AUTHOR (only the last two digits for each one): **22-****91
# Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# Copyright (C) Alexander B. Prokopyev, 2024, All Rights Reserved.
# Contact of the AUTHOR: a.prokopyev.resume at gmail dot com
#
# All source code and other content contained in this file is protected by copyright law.
# This file is licensed by the AUTHOR under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
#
# THIS FILE IS LICENSED ONLY PROVIDED FOLLOWING RESTRICTIONS ALSO APPLY:
# Nobody except the AUTHOR may alter or remove this copyright notice from any copies of this file content (including modified fragments).
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
#
# ATTENTION: If potential user's or licensee's country laws collide or are not compatible with the terms of this copyright notice or 
# if a potential user or licensee does not agree with the terms of this copyright notice then such potential user or licensee  
# is STRONGLY PROHIBITED to use this file by any method.
#================================================== The End of the Copyright Notice ======================================================

set -x;

Action=${1:-switch}; # create | switch
User=${2:-user1};
Duration=${3:-90}; # in days of certificate validity
DurationSec=$((Duration*3600*24)); # duration in seconds as required by the K8S CSR resource

#K8S_CertPath=xxx;
#CA_Cert=$K8S_CertPath/ca.crt;
#CA_Key=$K8S_CertPath/ca.key;

yq2()
{
	local YML_File=$1;
	Expression="${@:2}";
	yq --inplace "$Expression" "$YML_File"; # Following flavor of yq is required: https://github.com/mikefarah/yq/releases/download/v4.44.2/yq_linux_amd64
#	Example: echo hello1234 | UserName=user5 yq  '.metadata.name = strenv(UserName) | .spec.request=load_str("/dev/stdin")' csr.yml
}

yq3()
{
	local YML_File=$1;
	VarName=$2;
#	yq --inplace $VarName'=load_str("/dev/stdin")' "$YML_File";
	yq2 "$YML_File" $VarName'=load_str("/dev/stdin")';
}

yq4()
{
        local YML_File=$1;
        VarName=$2;
#       yq --inplace $VarName'=load_str("/dev/stdin")' "$YML_File";
        yq2 "$YML_File" $VarName'=(load_str("/dev/stdin") | tonumber)';
}

case $Action in
( user | create_user )
	openssl genrsa -out $User.key 2048;
	openssl req -new -key $User.key -out $User.csr -subj "/CN=$User";
#	openssl x509 -req -in $User.csr -CA $CA_Cert -CAkey $CA_Key -CAcreateserial -out $User.crt -days $Duration;	
	openssl req -in $User.csr -noout -text;
	
	cat $User.csr | base64 | tr -d '\n' > $User.csr.base64;
#	echo $User;
	
	echo -n $User | yq3 csr.yml .metadata.name;
	cat $User.csr.base64 | yq3 csr.yml .spec.request;

	echo -n $DurationSec | yq4 csr.yml .spec.expirationSeconds;
	
	cat csr.yml; # exit;

	kubectl delete csr --all;
	kubectl apply -f csr.yml; # && sleep 2s;
	kubectl certificate approve $User && sleep 2s;
	kubectl get csr -A;
	kubectl describe csr $User;
	kubectl get csr $User -o jsonpath='{.status.certificate}'  | base64 --decode > $User.crt;

	kubectl config set-credentials $User --client-certificate=$User.crt --client-key=$User.key;

	ClusterName=$(cat $KUBECONFIG | yq '.clusters[].name');
	kubectl config set-context $User --cluster=$ClusterName --user=$User;

#	Debug: kubectl logs -n kube-system
;;
( switch | switch_context )
	kubectl config use-context $User;
;;
esac;

