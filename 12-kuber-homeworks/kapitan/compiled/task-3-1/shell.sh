#!/usr/bin/env -vS bash -li


set -x;

SubStr="$1";
Container="$2";
Pkg="${3:-apt}";
N="${4:-1}"

#if [ -z $N ]; then
#	N=1;
#fi;

if ( ! [ -z $SubStr ] ) && ( ! [ -z $N ] ); then
	PodName=$(kubectl get pods | grep $SubStr | head -n $N | tail -n 1 | awk '{ print $1 }');
else
	echo "Error: incorrect args!";
	exit 1;
fi;

kube_exec()
{
	local Cmd="${@}";
	kubectl exec -ti pod/$PodName -c $Container -- bash -lc "$Cmd";
#	--user root	
	local Result=$?;
	return $Result;
}

if kube_exec ls /etc/debian-version; then
	Pkg="apt";
elif kube_exec ls /etc/alpine-release; then
	Pkg="apk";
fi;

case $Pkg in
	( apt )
		Cmd="apt-get update; apt-get install -y net-tools htop telnet; netstat -anp4; bash";
	;;
	( apk )
		Cmd="apk update; apk add net-tools htop inetutils-telnet; netstat -anp4; bash";
	;;
esac;

#kubectl exec -ti pod/$PodName -c $Container -- bash -lc "$Cmd";
kube_exec $Cmd;
