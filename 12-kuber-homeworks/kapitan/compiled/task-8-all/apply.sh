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



source /Homework/12-kuber-homeworks/kapitan/k8s.sh;

set -x;

Target="task-8-all";
#TargetN=$(echo $Target | cut -f 3 -d '-');
#TargetLabel="target$TargetN";
Namespace=task-8-all;

#PodName="tool";
#DeploymentName="lesson";

#set | grep -i kube;

killall kubectl;

if [ -z "$Namespace" ] ; then
	echo "Error: empty Namespace!";
	exit 1;
else
	kubectl delete namespace $Namespace;
        kubectl delete ClusterIssuer linode-dns01;
        kubectl delete ClusterIssuer ingress-http01;
fi

kubectl create namespace $Namespace;

kubectl config set-context --current --namespace=$Namespace;

#apply_step()
#{
#	StepN=$1;
#
#	kubectl apply -f objects.yml --selector "position=step-$StepN";
#	sleep 15s;
#	kubectl get all -o wide;
#}


#kubectl apply -f secrets.yml;
kubectl apply -f objects.yml;
sleep 25s;
kubectl get all -o wide;
kubectl get Issuer -o wide -A;
kubectl get Certificate -o wide -A;
kubectl get Secret -o wide -A;
kubectl get Ingress -o wide -A;

#./shell.sh exec combi tool curl nginx:9000 | head -n 5;


#./shell.sh exec task-8-all writer "tail -n 5 /mnt/writer.log";
#./shell.sh exec task-6-1 writer sh;
#./shell.sh exec task-6-1 reader bash;
#./shell.sh logs task-8-all reader;

#shell.sh exec task-6-2 tool "ls -al /mnt/";
#./shell.sh logs task-6-2 tool;