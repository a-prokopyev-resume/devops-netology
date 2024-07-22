#!/usr/bin/env -vS bash -li

set -x;

Namespace="web";

killall kubectl;

kubectl delete namespace web data;
kubectl create namespace web;
kubectl create namespace data;

kubectl config set-context --current --namespace=$Namespace;

kubectl apply -f objects.yml;
#--selector "$TargetLabel=$Target, step!=second";

sleep 30s;

kubectl get all -n web;
kubectl get all -n data;

PodName=$(kubectl get pods -n web -o json |  jq -r '.items[0].metadata.name');
kubectl logs pod/$PodName -c busybox;

