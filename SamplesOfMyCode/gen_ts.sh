#!/bin/bash

#=====begin of copyright notice=====
copyright()
{

echo -e "
'============================== The Beginning of the Copyright Notice =====================================================================
' The AUTHOR of this file is Alexander Borisovich Prokopyev born on December 20,1977 resident at Uritskogo str., Kurgan, Russia
' More info can be found at the AUTHOR's website: http://www.aulix.com/resume
' Contact: alexander.prokopyev at aulix dot com
' Copyright (c) Alexander B. Prokopyev, 2021
' 
' All materials contained in this file are protected by copyright law.
' Nobody except the AUTHOR may alter or remove this copyright notice from copies of the content.
' 
' The AUTHOR explicitly prohibits to use this content by any method without a prior authentic written hand-signed permission of the AUTHOR.
'================================= The End of the Copyright Notice ========================================================================
";

}

copyright;
#=====end of copyright notice=====

# Related info:
# https://cpdn.cryptopro.ru/content/pkisdk/html/TSP/tsputil/makestamp.html
# Deb packages:
# dpkg -i lsb-cprocsp-base_5.0.12000-6_all.deb  lsb-cprocsp-capilite-64_5.0.12000-6_amd64.deb lsb-cprocsp-rdr-64_5.0.12000-6_amd64.deb lsb-cprocsp-kc1-64_5.0.12000-6_amd64.deb lsb-cprocsp-rdr-64_5.0.12000-6_amd64.deb cprocsp-pki-cades-64_2.0.14071-1_amd64.deb
# Requires cprocsp-pki-cades
# /opt/cprocsp/bin/amd64/tsputil license

set -x;

SrcDir=$1;
Label=$2;
Option1=$3; # e.g. no_copy

TimestampSubDir1=".timestamp";
TimestampSubDir2="$(date +\%Y_\%m_\%d__\%H_\%M_\%S)";
if [ -n "$Label" ]; then
	TimestampSubDir2=$TimestampSubDir2"___"$Label;
fi;
StatusSubDir=".status";
GoodStatusSubDir=".good_status";
OriginalSourceSubDir=".src";

declare -A Servers; #arr["key1"]=val1

specify_bad_TSPs()
{
# === BAD
# --- Code 456 means need a password?
# --- Valid 13 years:
	Servers["cryptopro"]="http://www.cryptopro.ru/tsp/tsp.srf"; # often 456 on the same IP, 2 times per day good
	Servers["cryptopro2"]="http://qs.cryptopro.ru/tsp/tsp.srf"; # often 456 on the same IP, 2 times per 10 min good
	Servers["cryptopro3"]="http://qs.cryptopro.ru/tsp2012/tsp.srf";
#	Servers["ntssoft"]="http://ocsp.ntssoft.ru/tsp/tsp.srf";
#	Servers["ucparma1"]="http://ocsp.ucparma.ru/tsp/tsp.srf"; # NTSoft clone
#	Servers["ucparma2"]="http://ocsp2.ucparma.ru/tsp/tsp.srf"; # NTSoft clone	
# --- Valid for unknown period:
#	Servers["enotary"]="http://tsp.e-notary.ru/tsp2012/tsp.srf"; # 456
#	Servers["ncarf"]="http://tsp.ncarf.ru/tsp/tsp.srf"; # 456
# 	Servers["enotary"]="http://tsp.e-notary.ru/tsp/tsp.srf"; # 456
# --- Valid only 1 year:
#	Servers["taxnet1"]="http://tsp.taxnet.ru/tsp/tsp.srf"; # 456
#	Servers["taxnet2"]="http://tsp2.taxnet.ru/tsp/tsp.srf"; # 456

# --- Code 10:
#	Servers["enotary2"]="http://tsptest.e-notary.ru"; # exit code 10

#--- Test servers:
	Servers["cryptopro6_test"]="http://testca2012.cryptopro.ru/tsp/tsp.srf";
	Servers["cryptopro7_test"]="http://cryptopro.ru/tsp/tsp.srf";
# --- Other:
	Servers["digt"]="http://ca.digt.ru/tsp/tsp.srf";

# --- Obsolete:
#	Servers["sertum_old"]="http://pki.sertum-pro.ru/tsp/tsp.srf"; # Old algo
#	Servers["skbkontur_old"]="http://pki.skbkontur.ru/tsp/tsp.srf"; # Old algo
#	Servers["tensor_old"]="http://tax4.tensor.ru/tsp/tsp.srf # Old algo
#	http://testca.cryptopro.ru/tsp/tsp.srf # Old algo
}

specify_good_TSPs()
{
#===GOOD
# --- Valid 13 years, bad_cert_chain (исправимо):
	Servers["sertum"]="http://pki.sertum-pro.ru/tsp2012/tsp.srf"; 
	Servers["skbkontur"]="http://pki.skbkontur.ru/tsp2012/tsp.srf";
# --- Valid 10 years, bad_cert_chain (исправимо):
	Servers["itk23"]="http://service.itk23.ru/tsp/tsp.srf"; # bad_cert_chain
	Servers["itcom"]="http://service.itk23.ru/itcomTSP/tsp.srf"; # bad_cert_chain
# --- Valid only 1 year:	
	Servers["tensor"]="http://tax4.tensor.ru/tsp-tensor_gost2012/tsp.srf";	
	Servers["taxcom"]="http://tsp.taxcom.ru/tsp/tsp.srf";
	Servers["fns"]="http://pki.tax.gov.ru/tsp/tsp.srf";
}

# SKB & Certum OCSPs:
#/ocsp/ocsp.srf
#/ocspq/ocsp.srf
#/ocspn2/ocsp.srf
#/ocsp2012/ocsp.srf"

specify_good_TSPs;
#specify_bad_TSPs;

TSP_util()
{
#	globals: $File, $URL, $Srv
	HashLength=${1:-256};

	case $HashLength in
	( 256 )
		Alg="1.2.643.7.1.1.2.2";
	;;
	( 512 )
		Alg="1.2.643.7.1.1.2.3";
	;;
	esac;
#	echo $Alg;
	
	TSPFile="$File".$Srv.$HashLength.tsr;

#	proxychains 
	/opt/cprocsp/bin/amd64/tsputil makestamp --alg=$Alg --cert-req --nonce=yes -u $URL "$File" "$TSPFile" 2>&1 1>"$TSPFile".status;
	ExitCode=$?;
# HTTP error 456, the client SHOULD stop sending requests to the server and then prompt the user to contact the administrator.	

	if [ $ExitCode -eq 0 ];  then
		mv "$TSPFile".status "$TSPFile".good;
		return 0;
	else
		echo "Exit code: $ExitCode" >> "$TSPFile".status;
		mv "$TSPFile".status "$TSPFile".bad.$ExitCode;
		if [ $ExitCode -eq 9 ]; then
			mv "$TSPFile" "$TSPFile".bad_cert_chain;
			return 0;
		else
			rm "$TSPFile";
			return $ExitCode;
		fi;
	fi;
}

gen_ts()
{ 
	File=$1;
	for Srv in ${!Servers[@]}; do
	{
		URL=${Servers[$Srv]};
		echo "===== $Srv : $URL";
		TSP_util 256;
		TSP_util 512;
#		if TSP_util 256 || TSP_util 512; then
#		fi;
#		/opt/cprocsp/bin/amd64/tsputil makestamp --alg=1.2.643.7.1.1.2.2 --cert-req --nonce=yes -u $URL $File $File.$Srv.256.tsr;
#		/opt/cprocsp/bin/amd64/tsputil makestamp --alg=1.2.643.7.1.1.2.3 --cert-req --nonce=yes -u $URL $File $File.$Srv.512.tsr;
	} done;
	if [ "$Option1" != "no_copy" ]; then
		cp -H "$File" "$SrcCopyDir"/;
	fi;
}

# ----------------------------



#/etc/init.d/cprocsp start;

TSDir1="$SrcDir/$TimestampSubDir1"
TSDir="$TSDir1/$TimestampSubDir2";
StatusDir="$TSDir/$StatusSubDir";
GoodStatusDir="$StatusDir/$GoodStatusSubDir";
SrcCopyDir="$TSDir/$OriginalSourceSubDir";

#RND=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c 8`;
#mv "$TSDir" "$TSDir.$RND";
#mv "$StatusDir" "$StatusDir.$RND";

mkdir -p "$TSDir";
mkdir "$StatusDir"; 
mkdir "$GoodStatusDir";
mkdir "$SrcCopyDir";

#Files=${@};

#test1()
#{
#	echo $1;
#}

set +x;
source /usr/bin/env_parallel.bash;
find "$SrcDir" -maxdepth 1 -not -name "*~" -type f -print0 | env_parallel --null --jobs 3 gen_ts;
set -x;

#exit;

if ! ls "$SrcDir"/*.tsr.*; then
	rm -Rf "$TSDir";
#	echo === "$TSDir"
else
	mv "$SrcDir"/*.tsr.good "$GoodStatusDir/";
	mv "$SrcDir"/*.tsr.bad.* "$StatusDir/";
	mv "$SrcDir"/*.tsr* "$TSDir/";
fi;

if ! ls "$TSDir1"/*_*; then
	rmdir "$TSDir1";
#	echo === "$TSDir1"
fi;


#для отладки включите логирование
#/opt/cprocsp/sbin/amd64/cpconfig -loglevel сades -mask 0xF
#/opt/cprocsp/sbin/amd64/cpconfig -loglevel tsp -mask 0xF
#/opt/cprocsp/sbin/amd64/cpconfig -loglevel ocsp -mask 0xF
#воспроизведите ошибку.
#сообщения будут видны в sudo journalctl -f
#вернуть логирование обратно на прежний уровень mask 0x1

# Ошибка: gen_ts.sh не убирает файлы с точкой в начале имени типа .gitignore