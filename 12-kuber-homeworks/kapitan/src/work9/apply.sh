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

./kube_config.sh switch admin;

if [ -z "$Namespace" ] ; then
	echo "Error: empty Namespace!";
	exit 1;
else
	kubectl delete namespace $Namespace;
fi

kubectl create namespace $Namespace;

User={{ P.netology.student.user }};
./kube_config.sh create_user $User;

kubectl config set-context --current --namespace=$Namespace;

kubectl apply -f objects.yml;
sleep 25s;
kubectl get all -o wide;

./kube_config.sh switch $User;

kubectl get all -o wide;

#./shell.sh exec combi tool curl nginx:{{ P.NginxServicePort }} | head -n 5;


#./shell.sh exec task-8-all writer "tail -n 5 /mnt/writer.log";
#./shell.sh exec task-6-1 writer sh;
#./shell.sh exec task-6-1 reader bash;
#./shell.sh logs task-8-all reader;

#shell.sh exec task-6-2 tool "ls -al /mnt/";
#./shell.sh logs task-6-2 tool;
