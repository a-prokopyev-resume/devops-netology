#!/usr/bin/env -vS bash -li

#=============================================== The Beginning of the Copyright Notice ===================================================
# The AUTHOR of this file and the owner of all exclusive rights in this file is Alexander Borisovich Prokopyev
# born on December 20, 1977 resident of the city of Kurgan, Russia;
# Series and Russian passport number of the AUTHOR (only the last two digits for each one): **22-****91
# Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# Copyright (C) Alexander B. Prokopyev, 2024, All Rights Reserved.
# Contact of the AUTHOR: a.prokopyev.resume at gmail dot com
# WWW: https://github.com/a-prokopyev-resume/devops-netology/
#
# All source code and other content contained in this file is protected by copyright law.
# This file is licensed by the AUTHOR under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
#
# THIS FILE IS LICENSED ONLY PROVIDED FOLLOWING RESTRICTIONS ALSO APPLY:
# Nobody except the AUTHOR may alter or remove this copyright notice from any copies of this file content (including modified fragments).
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
#
# ATTENTION: If potential user's or licensee's country laws collide or are not compatible with the terms of this copyright notice or 
# if a potential user or licensee does not agree with the terms of this copyright notice then such potential user or licensee  
# is STRONGLY PROHIBITED to use this file by any method.
#================================================== The End of the Copyright Notice ======================================================


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