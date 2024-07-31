kubectl get namespaces --no-headers | awk '{ print $1 }' | grep -v ingress-nginx | grep -v kube;


