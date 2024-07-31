#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt;
kubectl create secret tls domain-cert-secret --namespace task-8-all --key=tls.key --cert=tls.crt -o yaml > domain-cert-secret.yml;
