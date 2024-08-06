set -x;

kubectl delete ns drone;
kubectl delete ns app1;
kubectl delete ns app2;

#helm install --namespace drone drone drone/drone -f values.yaml --create-namespace;

helm install  drone1 charts/drone/ -f values1.yaml --namespace app1 --create-namespace;
helm install  drone2 charts/drone/ -f values2.yaml --namespace app1 --create-namespace;
helm install  drone3 charts/drone/ -f values3.yaml --namespace app2 --create-namespace;

sleep 15s;

kubectl get  all -n app1;
kubectl get  all -n app2;

#kubectl expose deployment drone3 --name drone3-np --type=NodePort --port=80 --target-port=80 -n app2;
kubectl port-forward deployment/drone2 80:80 -n kubernetes-dashboard -n app1;

