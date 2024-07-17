#!/usr/bin/env -vS bash -li

set -x;

Target="{{ inventory.parameters.target_name }}";
TargetN=$(echo $Target | cut -f 3 -d '-');
TargetLabel="target$TargetN";
NameSpace=$Target;
LocalPort="{{ inventory.parameters.LocalPort }}";
RemotePort="{{ inventory.parameters.RemotePort }}";
ServicePort="{{ inventory.parameters.ServicePort }}";
PodName="{{ inventory.parameters.PodName }}";
ServiceName="{{ inventory.parameters.ServiceName }}";

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

kubectl apply -f objects.yml --selector "$TargetLabel=$Target";
#--field-selector='kind!=Service';

sleep 5s;

if kubectl get svc --no-headers 2>&1 | grep "No resources found in"; then
#if [ "$ServiceName" == "None" ]; then
	ForwardTarget="pod/$PodName";
	ForwardPort2=$RemotePort;
else
	ForwardTarget="service/$ServiceName";
	ForwardPort2=$ServicePort;
fi;

#screen -dm /bin/bash -lc "
kubectl port-forward $ForwardTarget $LocalPort:$ForwardPort2 &
#";
#--address='0.0.0.0'

(
	sleep 3s && \
	curl --get localhost:$LocalPort && \
	kubectl get all
);
