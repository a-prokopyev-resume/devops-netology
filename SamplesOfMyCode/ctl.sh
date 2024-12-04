#!/bin/ion
#-x
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
# Anybody except the AUTHOR is STRONGLY PROHIBITED to use this script without explicit authentic permission of the AUTHOR
# Following explicit permissions are all required simultaneously:
# 1) In writting and hand signed by the AUTHOR
# 2) Signed with his qualified digital signature of the AUTHOR
# 3) A verbal AUTHOR consent is required too
#
# FOLLOWING RESTRICTIONS ALSO APPLY:
# Nobody except the AUTHOR may alter or remove this copyright notice from any legal copies of this file content (including modified fragments).
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
#
# ATTENTION: If potential user's or licensee's country laws collide or are not compatible with the terms of this copyright notice or 
# if a potential user or licensee does not agree with the terms of this copyright notice then such potential user or license 
# is STRONGLY PROHIBITED to use this file by any method.
#================================================== The End of the Copyright Notice ======================================================


let ShallTunnel="yes"; # yes | no
#let USB_HUB="4-1";
#let USB_HUB="2-2";
#let USB_Mouse="2-1";
let Host="usb";
let HostMAC="00:15:58:c5:a2:0c";


let IgnoreHostKeyCheking=" -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' ";

fn accept_new_ssh_host_key # does not work yet, need to fix later
	su -lc "ssh-keygen -f /home/usb/.ssh/known_hosts -R usb" usb;
#	su -lPc "ssh -o 'StrictHostKeyChecking accept-new' root\@usb exit" usb; # does not save acceptance? need to fix
	su -lPc "ssh root\@usb exit" usb; # accept manually
end;

fn ssh_to_usb_host Args:[str]
	let Cmd="";
	let Cmd="@Args";
#	su -lPc 
	su -Ppc "ssh -t $IgnoreHostKeyCheking -o 'SendEnv SSH_AUTH_SOCK' root\@usb $Cmd" usb; # while acceptance not fixed above
#	su -lPc "ssh -t root\@usb $Cmd" usb;
end;

fn ssh_to_usb_host_non_int Args:[str]
#	debug on
	let Cmd="";
	let Cmd="@Args";
#	let InputPipe=$(cat);
#	cat $InputPipe |

	su -lPc "timeout 30s  ssh $IgnoreHostKeyCheking root\@usb $Cmd" usb | grep -v -P 'Warning|Connection'; # while acceptance not fixed above
#	su -lPc "ssh -t root\@usb $Cmd" usb;
end;

fn usb_chroot Args:[str]
	ssh_to_usb_host [ "chroot /mnt/chroot/bookworm" @Args ];
end;

fn start_ssh_tunnel;
	screen -S usb -md su -lPc "AUTOSSH_POLL=3 autossh $IgnoreHostKeyCheking -M 0 -o 'ServerAliveInterval 1'  -o 'ServerAliveCountMax 1' -L 3240:localhost:3240 root\@usb /utils/net/usbip/ping.sh" usb;
# | tee -a /var/log/usbip_ping.log;	
end;

fn usb_ports Action;
	match $Action
		case "attach"
			modprobe usbip-core;
			modprobe vhci-hcd;
			sleep 1s;
			
#			ssh_to_usb_host [ /utils/net/usbip/host_ctl.sh ports ] | grep -v -P 'Warning|Connection' > /tmp/usb_ports.txt;
			ssh_to_usb_host_non_int [ /utils/net/usbip/host_ctl.sh ports ] > /tmp/usb_ports.txt;
			for Port in @(cat /tmp/usb_ports.txt);
#				echo $Port;
				usbip attach -r $Host -b $Port;
			end;
#			for USB_Port in 1...4;
#				usbip attach -r $Host -b $USB_HUB.$USB_Port;
#			end;
		case "detach"				
			for USB_Port in 0...3;
				usbip detach -p 0$USB_Port;
			end;
		
			sleep 1s;
			rmmod -f vhci_hcd;
			sleep 1s;
			rmmod -f usbip_host;
			sleep 1s;
			rmmod -f usbip_core;
			sleep 1s;
		case _
			echo "Error: unknown ports action $Action !";
			exit 2;
		end;
end;

#let USB_HUB=$() # does not work?
#usb_chroot [ "usbip list -l" ] | grep -i mouse -B 1 | head -n 1 | awk '{ print $3 }' | cut -b 1-3 > /tmp/USB_HUB.txt; 
#let USB_HUB=$(cat /tmp/USB_HUB.txt);
#usb_chroot [ "usbip list -l" ] | grep -i keyboard -B 1 | head -n 1 | awk '{ print $3 }' | cut -b 1-3 > /tmp/USB_Keyboard.txt; 
#let USB_Keyboard=$(cat /tmp/USB_Keyboard.txt);

fn show_status;
       	ssh_to_usb_host_non_int [ "sensors"  ] | grep -v -P 'N/A|coretemp' | grep -P 'temp|fan|crit'; 
	ssh_to_usb_host_non_int	[ "uptime" ] | grep "up";
	echo -n "Remote iptables rules: "; ssh_to_usb_host_non_int [ "iptables -L -n" ] | wc -l;
       	echo;
	
	echo "===> Remote usbip list:";
# 	$USB_HUB ===> Remote lsusb:"
#	ssh_to_usb_host	[ "lsusb" ] | grep -i -P 'mouse|acr|keyboard';
	ssh_to_usb_host_non_int [ /utils/net/usbip/host_ctl.sh devs ];
#	usb_chroot [ "usbip list -l" ];
	echo;

	echo "===> Available for attachment (usbip list -r), localhost:3240 is displayed when tunnelled via SSH:"
	debug on;
	usbip list -r $Host;
	usbip list -r usb;
	debug off;
	echo;
#	sleep 2s;
		
	echo "===> Already attached:";
	bash -lc "usbip port 2>/dev/null";
	echo;
#	sleep 1s;
		
	echo "===> Local lsusb:"
	lsusb | grep -i -P "mouse|acr|keyboard";
#	echo;

#	echo "===> Loaded local kernel modules:"
#	lsmod | grep usbip;
#	echo;
end;

fn sync_date;
		let D=$(date +"%Y-%m-%d");
		ssh_to_usb_host_non_int [ "date -s $D" ];
		let D=$(date +"%H:%M:%S");
		ssh_to_usb_host_non_int [ "date -s $D" ];
end;

fn randomize_mac
#	debug on;
	ssh_to_usb_host_non_int [ macchanger --random ens2 ] > /dev/null;
	sleep 0.5s; ping -q -w 1 usb;
	macchanger --random eth2 > /dev/null;
	sleep 0.7s; ping -q -w 1 usb;
#	debug off;
end;

let Action=@args[1];

match $Action
	case "wake"
		etherwake -D -b -i eth2 $HostMAC;
		exit;
		
	case [ "attach" "detach" "init" "restart" "reattach" "reconnect" "retach" "status" ]

		if test $Action != "status" then
			rmmod lkrg;			
		end;
		
		if test $ShallTunnel == "yes";
			if not timeout 3s nc -zv localhost 3240;
				start_ssh_tunnel;
				sleep 1s;
			end;	
			let Host="localhost"; # when tunneled over SSH
		end;
end

#randomize_mac;

match $Action 
	case "attach"
		modprobe input_leds;
		usb_ports attach;
		show_status;
	case "detach"
		usb_ports detach;
	case [ "reattach" "reconnect" "retach" ]
		usb_ports detach;
		sleep 1s;		
		usb_ports attach;
	case "init_host"
		usb_ports detach;
		ssh_to_usb_host [ /utils/net/usbip/host_ctl.sh init ];
	case "restart"
		debug on;
#		sync_date;
		usb_ports detach;
#		randomize_mac;
		ssh_to_usb_host_non_int [ /utils/net/usbip/host_ctl.sh init ];
		usb_ports attach;
		sleep 3s;
		show_status;
	case "date" # sync
		sync_date;
#	case "accept" # Does not work yet, need fixing later!
#		accept_new_ssh_host_key;
	case "ssh"
#		debug on;
		let Args=[];
		if test $len(@args) -gt 2;
			let Args=[ @args[2..] ];
		end;
		ssh_to_usb_host [ @Args  ];
	case "display"
		let State=@args[2];
		ssh_to_usb_host_non_int [ chroot /mnt/chroot/bookworm vbetool dpms $State ];
	case "tunnel"
		start_ssh_tunnel;
	case "status"
		show_status;
	case "mac" # randomize
		# disable remote firehol
		# change remote mac
		# change local mac
		# enable remote firehol
		randomize_mac;
	case "mac_cycle"
#		debug on;
		while true;
			date;
			randomize_mac;

			let R=$(random); let R//=165; let R+=60;
			
#			sleep 10m;
			debug on;
#			sleep $R""s;
			ping -i 0.05 -D -w $R usb; # | tee -a /var/log/usbip_ping.log;
			debug off;
		end;
	case "attach_cycle"
#		debug on;
		while true;
			date;
#			randomize_mac;

#			let R=$(random); let R//=165; let R+=60;
			
#			sleep 10m;
#			debug on;
#			sleep $R""s;
#			ping -i 0.05 -D -w $R usb | tee -a /var/log/usbip_ping.log;
#			debug off;
#			usb_ports attach;
			/utils/net/usbip/restart.sh;
			sleep 5m;
		end;		
	case "chroot"
#		debug on;
		let Args=[];
		if test $len(@args) -gt 2;
			let Args=[ @args[2..] ];
		end;
		usb_chroot [ @Args ];
	case "chroot2"
		ssh_to_usb_host [ /utils/custom/chroot.sh ];		
	case _
		echo "Error: unknown action: $Action !";
		exit 1;
end;

#randomize_mac;

match $Action
	case [ "attach" "detach" "init" "restart" "reattach" "reconnect" "retach" ]
		modprobe lkrg; sysctl -w lkrg.block_modules=1;
end;

