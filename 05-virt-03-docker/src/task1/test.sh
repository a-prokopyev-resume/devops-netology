set -x;
docker rmi aprokopyev/devops-netology-05-virt-03-nginx:v1 -f;
docker run -p 8080:80 --detach --name 05-virt-03-nginx aprokopyev/devops-netology-05-virt-03-nginx:v1
sleep 3s;
curl localhost:8080 | cat;
docker stop 05-virt-03-nginx;
/utils/docker/clean_stopped.sh;