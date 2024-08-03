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


{% set P = inventory.parameters %}

source /Homework/12-kuber-homeworks/kapitan/k8s.sh;

set -x;

Target="{{ target }}";
#TargetN=$(echo $Target | cut -f 3 -d '-');
#TargetLabel="target$TargetN";
Namespace={{ P.Namespace }};

#PodName="tool";
#DeploymentName="lesson";

#set | grep -i kube;

killall kubectl;

if [ -z "$Namespace" ] ; then
	echo "Error: empty Namespace!";
	exit 1;
else
	kubectl delete deployment task-7-all;
	#kubectl delete  pod/task-7-1-6b8dfc46b6-nkxn8 --grace-period=0 --force 
	sleep 3s;
	
	#for i in {1..3}; do
		while true; do
			(timeout 10s kubectl delete namespace $Namespace) || (timeout 10s kubectl delete namespace $Namespace --grace-period=0 --force) || (timeout 10s kubectl delete pod --all --grace-period=0 --force);
			Result=$?;
			echo $Result;
			if [ $Result -eq 0 ]; then
				break;
			else
				sleep 5s;
			fi;
		done;
#	done;
	
	kubectl delete pv --all;
fi

kubectl create namespace $Namespace;

kubectl config set-context --current --namespace=$Namespace;

ExampleURL=https://raw.githubusercontent.com/kubernetes/examples/master/staging/volumes/nfs/;

apply_example()
{
	Manifest=$1;
	kubectl apply -f $ExampleURL/$Manifest;
}

#apply_example nfs-server-gce-pv.yaml;
kubectl apply -f nfs-server-pv.yml;
apply_example nfs-server-deployment.yaml;
apply_example nfs-server-service.yaml;
#kubectl describe services nfs-server;
sleep 45s;
kubectl get all;

#apply_example  nfs-pv.yaml;
#sleep 10s;

#apply_example  nfs-pvc.yaml;
#sleep 5s;

# replace service name by its IP address in the nfs pv definition to fix some nfs->dns resolution bug
NFS_IP_Address=$(kubectl get service nfs-server -o yaml | yq eval '.spec.clusterIP');
yq -i '(select(.metadata.name == "nfs") | .spec.nfs.server) = "'$NFS_IP_Address'"' objects.yml;

test_result()
{
	echo;
	echo "===> Test result:";
	kubectl describe deployment task-7-all | grep pvc -C 3;
	./shell.sh exec task-7-all writer "tail -n 5 /mnt/writer.log";
	#./shell.sh logs task-7-1 reader;
	./shell.sh exec task-7-all reader "tail -n 5 /mnt/writer.log";

}

switch_pvc()
{
	Name=$1;
	yq -i '(select(.kind == "Deployment" and .metadata.name == "task-7-all").spec.template.spec.volumes[] | select(.name == "shared").persistentVolumeClaim.claimName) = "'$Name'"' objects.yml;
}

switch_pvc pvc1;
kubectl apply -f objects.yml;

sleep 15s;
kubectl get all -o wide;
kubectl get pv -o wide;
kubectl get pvc -o wide;

kubectl describe pv local;
kubectl describe pv nfs;

test_result;

kubectl delete deployment task-7-all; sleep 3s;
switch_pvc pvc2;
kubectl apply -f objects.yml;
sleep 5s;
test_result;


#kubectl run -it --rm --restart=Never dnsutils2 --image=busybox -- sh -c "nslookup nfs-server"
#kubectl run -it --rm --restart=Never dnsutils --image=busybox -- sh -c nslookup nfs-server
#kubectl run -it --rm --restart=Never dnsutils2 --image=wbitt/network-multitool -- bash -lc "mount -t nfs -vvv -o nfsvers=4.2 nfs-server:/1 /mnt/"

#kubectl exec pod/task-7-1-6f869c54b7-bkklp  -c reader -- kill 1
