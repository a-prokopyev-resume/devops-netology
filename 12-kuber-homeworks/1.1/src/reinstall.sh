#!/usr/bin/env bash
#=============================================== The Beginning of the Copyright Notice ===================================================
# The AUTHOR of this file and the owner of all exclusive rights in this file is Alexander Borisovich Prokopyev
# born on December 20, 1977 resident of the city of Kurgan, Russia;
# Series and Russian passport number of the AUTHOR (only the last two digits for each one): **22-****91
# Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# Copyright (C) Alexander B. Prokopyev, 2024, All Rights Reserved.
# Contact of the AUTHOR: a.prokopyev.resume at gmail dot com
# WWW: https://github.com/a-prokopyev-resume
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

Action=$1;

Version="v1.30.2+k0s.0";
#Version="v1.29.6+k0s.0";
#Version="v1.29.2+k0s.0";
#Version="v1.28.11+k0s.0";
#Version="v1.27.15+k0s.0";

SnapshotterDir="/var/lib/k0s/containerd/io.containerd.snapshotter.v1.zfs";
KubeConfig="/utils/k0s/config/k0s.yml";

zfs_destroy()
{
	zfs destroy data2/var/k0s -r;
}

zfs_recreate()
{
	
	zfs_destroy;
	zfs create data2/var/k0s;
	zfs create data2/var/k0s/containerd;
	zfs set mountpoint=legacy data2/var/k0s/containerd;
	mkdir -p $SnapshotterDir;
	mount $SnapshotterDir;
}

./stop.sh;
k0s reset;

case $Action in
	( destroy )
		zfs_destroy; exit;
	;;
	( * )
		zfs_recreate;
	;;
esac;

if curl -sSLf https://get.k0s.sh | K0S_VERSION=$Version sh; then
	if k0s install controller --single; then
		if /etc/init.d/k0scontroller start || systemctl start k0scontroller; then
			sleep 10s;
			k0s kubeconfig admin > $KubeConfig;
			chmod 500 $KubeConfig;
		fi;
	fi;
fi;

pstree;
#sleep 2m;
./pods.sh;
#./all.sh
