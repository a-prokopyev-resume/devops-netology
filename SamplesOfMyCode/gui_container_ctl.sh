#!/usr/bin/env bash
#=============================================== The Beginning of the Copyright Notice ===================================================
# The AUTHOR of this file and the owner of all exclusive rights in this file is Alexander Borisovich Prokopyev
# born on December 20, 1977 resident of the city of Kurgan, Russia;
# Series and Russian passport number of the AUTHOR (only the last two digits for each one): **22-****91
# Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# Copyright (C) Alexander B. Prokopyev, 2024, All Rights Reserved.
# Contact of the AUTHOR: a.prokopyev.resume at gmail dot com
#
# All source code and other content contained in this file is protected by copyright law.
# Anybody except the AUTHOR is STRONGLY PROHIBITED to use this file without explicit authentic permission of the AUTHOR
# Following explicit permissions are all required simultaneously:
# 1) In writting and authentic hand signed by the AUTHOR
# 2) Signed with a qualified digital signature of the AUTHOR
# 3) A verbal AUTHOR consent is required too
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

RootHomeDir=/mnt/X_projects/APP_DATA/docker;

Action=${1:-shell};
Name=${2:-tel1};
Options="${@:3}";

case $Name in
	( test )
		VNC_Session=10;
		ImageName="alpine_vnc:v1";
	;;	
	( tel1 )
		VNC_Session=11;
		ImageName="alpine_telegram:v1";
	;;
	( tel2 )
		VNC_Session=12;
		ImageName="alpine_telegram:v1";
	;;
	( apps )
                VNC_Session=14;
                ImageName="alpine_apps:v1";
        ;;
        ( deb )
                VNC_Session=15;
                ImageName="debian_apps:v1";
		Options1=" --cap-add=SYS_ADMIN "; # Chromium crashes without this option
#		Options1=" --security-opt seccomp=/utils/docker/image/desktop/chrome.json ";
        ;;
        ( deb2 )
                VNC_Session=16;
                ImageName="debian_apps:v1";
		Options1=" --cap-add=SYS_ADMIN "; # Chromium crashes without this option
#		Options1=" --security-opt seccomp=/utils/docker/image/desktop/chrome.json ";
        ;;
        
        ( debs )
                VNC_Session=150;
                ImageName="debian_apps_debs:v1";
        ;;
        ( dev )
                VNC_Session=16;
                ImageName="debian_dev:v1";
                Options1=" --privileged ";
        ;;        

	( * )
		echo "Error: unknown name: $Name !";
		exit 1;
	;;
esac;

VNC_Port=$((5900+$VNC_Session));
QT_VNC_Port=$((5910+$VNC_Session));

UserHomeDir=$RootHomeDir/$Name;

if ! [ -d $UserHomeDir ]; then
	 echo "Error: cannot find directory: $UserHomeDir !";
         exit 2;
fi;

check_port()
{	
	nc -z 127.0.0.1 $VNC_Port;
	local Result=$?;
	return $Result;
}

wait_port()
{
	local Timeout=${1:-10}; # in seconds
	for (( I=0; I<=$Timeout; I++ )); do
		check_port;
		Result=$?;
		if [ $Result -eq 0 ]; then
			return $Result;
		else
			echo "... waiting for open port ...";
			sleep 1s;
		fi;
	done;
	return 1; # Required VNC port is still not open
}

start_action()
{
#		( docker stop $Name ) 2>&1 | cat > /dev/null;	
		chmod 777 -R /dev/snd;
#		chmod 777 -R /dev/video0;
#		chmod 666 /dev/dsp;
		
		local Status=$(docker inspect $Name| jq -r '.[0].State.Status');
		Status=$(echo $Status | sed 's/null/missing/');
#		if [ $? -ne 0 ]; then
#			Status="missing";
#		fi;

		case $Status in
			( "exited" | "running" )


				docker start $Name; # \ 
#				2>&1 | cat > /dev/null;  # !!! comment out this line for debug

#				Note: hardended containers cannot restart because of missing shells!
				sleep 1s; # allow container to stop again if it fails
				if ! ( docker ps | grep $Name && wait_port 5); then # if not (container running and port is open at the same time) then
					( docker stop $Name && docker rm $Name ) || \
					( echo "Error: cannot stop container! exiting ..." && exit 1 );
				else
					echo "Debug: test port open?";
					timeout 1s telnet 127.0.0.1 5911;
#					exit 0;
				fi;
			;;
			
			( "missing" )
				# do nothing yet
			;;
			
			( * )
				echo "Unexpected container status: $Status ! exiting ...";
				exit 2;
			;;
		esac;
		
  		if [ $Status == "exited" ] || [ $Status == "missing" ]; then
			docker run -ti $Options $Options1 $Options2 --device /dev/snd -v $UserHomeDir:/home -v /download/docker/$Name:/download \
				-e VNC_Password=201277 -p $QT_VNC_Port:5900 -p $VNC_Port:5901 --name $Name $ImageName; # \
#					2>&1 | cat > /dev/null;  # !!! comment out this line for debug
					
# --device /dev/video0					
					
			if ! wait_port 10; then
				echo "Error: VNC port is not open yet even after docker stop+rm+run! exiting ...";
				exit 3;
			fi;
		fi;

}

harden1_action()
{
		docker exec $Name bash -lc "
			apk del rsync doas mc joe screen htop inetutils-telnet sakura xterm shadow;
			apk del mandoc man-pages tigervnc-doc alsa-tools-doc alsa-utils-doc;
			apk del alsaconf dash-binsh;
			apk del alsa-tools # special mixer for special sound cards
			apk del alsa-utils # aplay, etc.
		"; 
}

harden2_action()
{
		docker exec $Name bash -lc "
			set -x;
#			apk del alsaconf;
			apk del bash;
			apk del apk-tools;

			rm /bin/sh; # echo $?;
			rm /usr/bin/perl; # echo $?;
			rm /bin/busybox; # echo $?; # Shall be called last
		";
}

start_action_helper()
{
		Options2=" --detach "; # !!! comment out this line for debug
		start_action \
			2>&1 | cat > /dev/null;  # !!! comment out this line for debug

		echo $VNC_Session;
}

cd /utils/docker/image/desktop/;

case $Action in
	( start ) # Try to start in the fastest way (start stopped container or run new one if missing)
		start_action_helper;

		case $Name in
			( deb )
				sleep 3s;
				docker exec -ti $Name bash -lc "
#					/etc/init.d/dbus start;
					rm -rf /home/vnc/.config/chromium/Singleton*;
				";
			;;
			( apps )
				docker exec -ti $Name bash -lc "
#					touch /run/openrc/softlevel;
#					rc-service dbus start;
					rm -rf /home/vnc/.config/chromium/Singleton*;
				";
			;;
		esac;
	;;
	
	( start_harden )
		start_action_helper;
		( 
			harden1_action; 
			harden2_action;
		) \
		2>&1 | cat > /dev/null;  # !!! comment out this line for debug
	;;
	
	( start_harden1 )
		start_action_helper;
		( 
			harden1_action; 
#			harden2_action;
		) \
		2>&1 | cat > /dev/null;  # !!! comment out this line for debug
	;;
	
	( restart )
		./ctl.sh stop $Name;
		./ctl.sh start $Name;
		 docker ps -a;
	;;
	
	( shell )
		docker exec -ti $Name /utils/ctl2.sh shell;
	;;
	
	( stop )
		docker stop $Name;
		docker rm $Name;
#		/utils/docker/clean_stopped.sh;
		docker ps -a;
	;;
	
	( unlink )
		cd $UserHomeDir/vnc && pwd && \
		(
			rm -RIv .cache;
			rm -RIv .local/share/TelegramDesktop/tdata/user_data
		);
	;;
	
	( ls | ps )
		docker ps -a;
	;;
	
	( links )
	     	set -x;
		cd $UserHomeDir/vnc && pwd && \
                (
                        ls -al; # .cache;
                        ls -al .local/share/TelegramDesktop/tdata; #/user_data
                );
	;;
	
	( clean )
		/utils/docker/clean_stopped.sh;
		docker ps -a;
	;;
	
	( inspect )
		docker inspect $Name | grep -C 0 -i cap;
		docker inspect $Name | grep -C 0 -i Privileged;
	;;
	
	( harden1 | harden2 )
		$Action"_action";
	;;	
	
	( harden )
		harden1_action;
		harden2_action;
	;;
	
	( check )
		if check_port; then
			echo "VNC port $VNC_Port is open";
		else
			echo "VNC port $VNC_Port is closed";
		fi;
		
	;;
esac;
