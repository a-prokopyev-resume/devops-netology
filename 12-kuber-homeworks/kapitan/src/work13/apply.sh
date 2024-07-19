#!/usr/bin/env -vS bash -li

{% set P = inventory.parameters %}

source /Homework/12-kuber-homeworks/kapitan/k8s.sh;

set -x;

Target="{{ target }}";
#TargetN=$(echo $Target | cut -f 3 -d '-');
#TargetLabel="target$TargetN";
Namespace={{ Namespace }};

#PodName="tool";
#DeploymentName="lesson";

#set | grep -i kube;

killall kubectl;

if [ -z "$Namespace" ] ; then
	echo "Error: empty Namespace!";
	exit 1;
else
	kubectl delete namespace $Namespace;
fi

kubectl create namespace $Namespace;

kubectl config set-context --current --namespace=$Namespace;

kubectl apply -f objects.yml;
#--selector "$TargetLabel=$Target, step!=second";

sleep 10s;

#if kubectl get svc --no-headers 2>&1 | grep "No resources found in"; then
kubectl get all -o wide;

./shell.sh init front tool;
./shell.sh init back tool;


./shell.sh exec front tool curl back-service:{{ ToolServicePort+2 }} | head -n 5;
./shell.sh exec front tool curl --connect-timeout 5 cache-service:{{ ToolServicePort+3 }} | head -n 5;
./shell.sh exec back tool curl cache-service:{{ ToolServicePort+3 }} | head -n 5;


#ExtIP=$(kubectl describe node | grep ExternalIP | awk '{ print $2 }');
#curl $ExtIP:30001 | head -n 5;
#curl $ExtIP:30002 | head -n 5;

echo;
curl work5.com | head -n 5;
echo;
curl work5.com/api | head -n 5;
