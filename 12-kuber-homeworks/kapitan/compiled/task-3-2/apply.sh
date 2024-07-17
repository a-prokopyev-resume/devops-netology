#!/usr/bin/env -vS bash -li

set -x;

source /Homework/12-kuber-homeworks/kapitan/k8s.sh;

Target="task-3-2";
TargetN=$(echo $Target | cut -f 3 -d '-');
TargetLabel="target$TargetN";
NameSpace=$Target;

PodName="$Target-pod";
ServiceName="$Target-service";
DeploymentName="$Target-deployment";

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

kubectl apply -f objects.yml --selector "$TargetLabel=$Target, step!=second";

sleep 5s;

#if kubectl get svc --no-headers 2>&1 | grep "No resources found in"; then
kubectl get all;

case $Target in
	( task-3-1 )
		kubectl scale --replicas=2 deployment.apps/task-3-1-deployment;
		sleep 3s;
		kubectl get deployments;
		kubectl exec task-3-1-pod -- curl task-3-1-service:80 | head -n 5;
		kubectl exec task-3-1-pod -- curl task-3-1-service:81 | head -n 5;
	;;
	
	( task-3-2 )
		kubectl apply -f objects.yml --selector "$TargetLabel=$Target, step=second";
		sleep 20s; kubectl get all;
		sleep 20s; kubectl get all;
	;;
esac;
