#Image="kapitan:pip3_upgrade";
#Image="kapicorp/kapitan";
Image="projectsyn/kapitan:v0.29.5";
#Image="vshn/kapitan";


alias kapitan2='docker run -t --rm --user root -v $(pwd):/src:delegated kapicorp/kapitan'
alias kapitan-start='docker run -d -v $(pwd):/mnt:delegated --name kapitan --entrypoint=/bin/ash '$Image' -c "sleep 10h"; docker ps -a';
alias kapitan-rm='docker stop kapitan; docker rm kapitan; docker ps -a';
alias kapitan='docker exec -ti -e GIT_PYTHON_REFRESH=0 --workdir /mnt/ kapitan kapitan';



