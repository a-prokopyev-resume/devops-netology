#!/bin/bash

#=============================================== The Beginning of the Copyright Notice ===================================================
# The AUTHOR of this file and the owner of all exclusive rights in this file is Alexander Borisovich Prokopyev
# born on December 20, 1977 resident of the city of Kurgan, Russia;
# Series and Russian passport number of the AUTHOR (only the last two digits for each one): **22-****91
# Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# Copyright (C) Alexander B. Prokopyev, 2024, All Rights Reserved.
# Contact of the AUTHOR: a.prokopyev.resume at gmail dot com
#
# THIS IS PROPRIETARY FILE!
# All source code and other content contained in this file is protected by copyright law.
# Anybody except the AUTHOR is STRONGLY PROHIBITED to use this file without explicit authentic permission of the AUTHOR
# Following explicit permissions are all required simultaneously:
# 1) In writting and authentic hand signed by the AUTHOR
# 2) A verbal AUTHOR consent is required too
# 3) Aunthentically authorized by the AUTHOR from his account in avito.ru chat regarding following lot:
#      https://2ly.link/20qqJ
#      https://www.avito.ru/moskva/predlozheniya_uslug/devops_inzhener_trener_repetitor_linux_dba_resheniya_3933899442
#
# FOLLOWING RESTRICTIONS ALSO APPLY:
# Nobody except the AUTHOR may alter or remove this copyright notice from any legal copies of this file content (including modified fragments).
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
#
# ATTENTION: If potential user's or licensee's country laws collide or are not compatible with the terms of this copyright notice or 
# if a potential user or licensee does not agree with the terms of this copyright notice then such potential user or licensee 
# is STRONGLY PROHIBITED to use this file by any method.
#================================================== The End of the Copyright Notice ======================================================


#set -x;
#echo debug: ${@}; exit;

source /etc/aptly/variables;
AptlyDataDir=$(jq -r '.rootDir' $ConfigFile);

Script=$0;
ScriptName=$(basename $0);
Action=${1:-$ScriptName};
DebianGPGKeys="648ACFD622F3D138 0E98404D386FA1D9 DCC9EFBF77E11517";

update_keys()
{
	gpg --no-default-keyring --keyring trustedkeys.gpg --keyserver keyserver.ubuntu.com --recv-keys $DebianGPGKeys;
}

publish()
{
	$AptlyCmd snapshot create $Snapshot from mirror $Mirror;
	$AptlyCmd publish snapshot -skip-signing $Snapshot; # -component=main,contrib,non-free
}

unpublish()
{
	$AptlyCmd publish drop $Release;
	$AptlyCmd --force snapshot drop $Snapshot;
}

case $Action in
	( docker_start )
		echo $Action;
	;;
	
	( entrypoint.sh )
		echo $Action;
	;;
	
	( delete )
		unpublish;
		$AptlyCmd --force mirror drop $Mirror;
		if [ -n $AptlyDataDir ]; then
			rm -rI $AptlyDataDir/*;
		fi;
	;;
	
	( create )
		update_keys;
		$AptlyCmd mirror create $MirrorOptions -filter="$Packages" $Mirror $Uplink/ $Release $Components;
		$AptlyCmd mirror update $Mirror;
		publish;
	;;
	( recreate )
		$Script delete;
		$Script create;
	;;
	( edit | update )
		unpublish;
		update_keys;
		$AptlyCmd $MirrorOptions -filter="$Packages" mirror edit $Mirror;
 		$AptlyCmd mirror update $Mirror;
 		publish;
	;;
	( status )
		echo "===> Mirror:";
		$AptlyCmd mirror list;
		$AptlyCmd mirror show $Mirror;
		echo "===> Snapshot:";
		$AptlyCmd snapshot list;
		$AptlyCmd snapshot show $Snapshot;
		echo "===> Published for apt:";
		$AptlyCmd publish list;
		$AptlyCmd publish show $Release;
#		echo "===> Packages in repository:";
#		grep ^Package /var/lib/apt/lists/_download_aptly_data_public_dists_buster_main_binary-amd64_Packages | awk '{print $2}' | sort -u | wc -l;
          	echo "===> Aptly config:"
		$AptlyCmd config show;
		echo "===> Env variables:"
#		set -x;
#		set;
		printenv;
#		declare -p; # reveals the source !!!
#		source /etc/aptly/variables;
#		printenv;
	;;
#	( packages )
#	          grep ^Package /var/lib/apt/lists/_download_aptly_data_public_dists_buster_main_binary-amd64_Packages | awk '{print $2}' | sort -u;
#        ;;

	( keys )
		update_keys;
#		wget -O - http://deb.debian.org/debian/Release.key | gpg --no-default-keyring --keyring trustedkeys.gpg --import
#		https://ftp-master.debian.org/keys/release-10.asc
#		gpg --batch --quiet --generate-key gpg.txt;
#		gpg --list-secret-keys;
	;;
	( publish )
		publish;
	;;
	( sources )
		echo "deb [arch=amd64 trusted=yes] file://$DataDir/public/ $Release main";
	;;
	( custom )
		$AptlyCmd ${@:2};
	;;
esac;
