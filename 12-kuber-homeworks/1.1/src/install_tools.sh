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

add_repo()
{
	Name=$1;
	KeyURL="$2";
	Distro="$3";
	KeyRing="/etc/apt/keyrings/$Name.gpg";
	SourceFile="/etc/apt/sources.list.d/$Name.list";
	if curl -fsSL "$KeyURL" | gpg --dearmor -o $KeyRing; then
		echo "deb [signed-by=$KeyRing] $Distro" | tee -a $SourceFile;
	fi;
	chmod 644 $KeyRing $SourceFile ;
}

apt-get update && apt-get install gpg apt-transport-https --yes;

add_repo "helm" "https://baltocdn.com/helm/signing.asc" "https://baltocdn.com/helm/stable/debian/ all main";
add_repo "kube" "https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key" "https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /"; 

apt-get update && apt-get install --yes helm kubectl;
