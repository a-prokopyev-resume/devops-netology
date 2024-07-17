#!/usr/bin/env -vS bash -li

source /Homework/12-kuber-homeworks/kapitan/k8s.sh;

set -x;

Target="{{ inventory.parameters.target_name }}";
#TargetN=$(echo $Target | cut -f 3 -d '-');
#TargetLabel="target$TargetN";
NameSpace=$Target;

PodName="tool2";
DeploymentName="lesson";

#set | grep -i kube;

killall kubectl;

if [ -z "$NameSpace" ] ; then
	echo "Error: empty NameSpace!";
	exit 1;
else
	kubectl delete namespace $NameSpace;
fi

kubectl create namespace $NameSpace;

kubectl config set-context --current --namespace=$NameSpace;

kubectl apply -f objects.yml 
#--selector "$TargetLabel=$Target, step!=second";

sleep 10s;

#if kubectl get svc --no-headers 2>&1 | grep "No resources found in"; then
kubectl get all;

kubectl exec tool2 -- curl int:9001 | head -n 5;
kubectl exec tool2 -- curl int:9002 | head -n 5;

ExtIP=$(kubectl describe node | grep ExternalIP | awk '{ print $2 }');
curl $ExtIP:30001 | head -n 5;
curl $ExtIP:30002 | head -n 5;

