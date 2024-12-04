#!/bin/bash -e

# Compare to: https://github.com/Oefenweb/ansible-ssh-keys

copyright()
{
	echo -e "\
	THE \"AULIX_UTILS FOR DEBIAN AND CENTOS\" SOFTWARE PRODUCT \n\
	The AUTHOR of this file is Alexander Borisovich Prokopyev, Kurgan, Russia \n\
	More info can be found at the AUTHOR's website: http://www.aulix.com/resume \n\
	Contact: alexander.prokopyev at aulix dot com \n\
        
        Copyright (c) Alexander Prokopyev, 2006-2018 \n\
          
        All materials contained in this file are protected by copyright law. \n\
        Nobody except the AUTHOR may alter or remove this copyright notice from copies of the content. \n\
        This is a proprietary software \n\
           
        The AUTHOR explicitly prohibits to use this content by any method without a prior \n\
        written hand-signed permission of the AUTHOR. \n";
        
        echo "Examples:";
	echo "/utils/sec/ssh/keys.sh --action gen_server --host Host create a new server key";
	echo '/utils/sec/ssh/keys.sh --action gen_client --slot N  # key slot number in the $KeySlotDir';
	echo '/utils/sec/ssh/keys.sh --action show_slots';
	echo "/utils/sec/ssh/keys.sh --action link --host Host --slot N --clean_ak  # assign a new key from slot XXX to host";
	# ./keys.sh --action prep_server --host vps3
	echo;
        
}



CmdArgs=${@:3}; # Save all args except first --action XXX
source /utils/dev/bashopts.sh;
	trap 'bashopts_exit_handle' ERR;
	bashopts_setup -n "keys.sh" -d "SSH keys manipulation library" -s "$HOME/.config/keys_rc" -x -p;

	bashopts_declare -n Action -l action -o a -d "Action to do" -t enum -v 'nothing' \
		-e 'pc|prep_client' -e 'ps|prep_server' -e 'gs|gen_server' -e 'gc|gen_client' -e 'l|link' -e'n|nothing' -e'verify_sk' -e'verify_ck' -e'verify_pair' \
		-e'r|refresh_key' -e 's|status' -e 'verify' -e 'sck|show_ck' -e 'sak|show_ak' -e 'saks|show_aks' -e 'ckh|clean_kh' -e 'ckhs|clean_khs' -e 'copyright';

	bashopts_declare -n SSHServer -l host -d "SSH host" -t string;
	bashopts_declare -n TargetHosts -l targets -d "Target SSH hosts" -t string;
	bashopts_declare -n SwitchUser -l su -d "SU user to run SSH under it" -t string;
	bashopts_declare -n KeySlotN -l slot -o n -t number -d "Key slot number";
	bashopts_declare -n ShallCleanAllAK -l clean_all_ak -t boolean -d "Shall clean all keys except currrent one in authoirzed_keys2";
	bashopts_declare -n ShallCleanOldAK -l clean_ak -t boolean -d "Shall clean old keys in authoirzed_keys2";
	bashopts_declare -n KeepAKs -l keep_ak -t number -d "Keep this amount of existing keys in authoirzed_keys2";
	bashopts_declare -n ShallKeepClientKey -l keep_ck -t boolean -d "Do not regenerate client key, used for keys used for several hosts";
	bashopts_declare -n ShallLogSessions -l log_sessions -t boolean -d "Shall add session_log.sh command to authoirzed_keys2";

bashopts_parse_args "$@"; bashopts_process_opts;

#set -x;

debug_args()
{
	echo "CmdArgs: $CmdArgs";
	echo "Action: $Action";
	echo "SSH Host: $SSHServer";
	echo "Key Slot N: $KeySlotN";
	echo "ShallCleanOldAK: $ShallCleanOldAK";
	echo "KeepAKs: $KeepAKs";
	echo "ShallCleanAllAK: $ShallCleanAllAK";
	echo "ShallKeepClientKey: $ShallKeepClientKey";
	echo "ShallLogSessions: $ShallLogSessions";

#	exit;
}

#debug_args;
#exit;

heading()
{
	Caption=$1;
	echo -e "\n;=================== $Caption ========";
}

silent_ssh()
{
	Host=$1;
	Cmd=$2;
	ssh $Host -o "StrictHostKeyChecking no" "$Cmd";
}

KeySlotDir="/root/.ssh/keys"; # environment variable
KeyFileName="client_key";
UtilPath="/utils/sec/ssh";


# Updates LOCAL /etc/.ssh/ssh_config identities
use_slot()
{
	$UtilPath/keys_helper.pl $SSHServer "$KeySlotDir/$KeySlotN/$KeyFileName";
}

clean_kh_helper()
{
	Host=$1;
	ssh-keygen -R $Host;
	ssh-keygen -R [$Host]:443;
	ssh-keygen -R [$Host]:8443;
	ssh-keygen -R [$Host]:62453;
	ssh-keygen -R [$Host]:62454;
	ssh-keygen -R [$Host]:60222;
	ssh-keygen -R [$Host]:62622;
}

clean_known_hosts2()
{
	Host=$1;
	#IPAddress=$(perl -e 'use Shell; my $Sh=Shell->new; my $S=$Sh->nslookup("'$Host'"); $S=~s/.*\nAddress: (.*)\n.*/$1/s; print $S;');
	IPAddress=$(perl -e 'use Shell; my $Sh=Shell->new; my $S=$Sh->ping("-c 1 -w 1 '$Host'"); $S=~s/PING\s[\w\.]+\s\(([\d\.]+)\)\s56.*/$1/s; print $S;');
	clean_kh_helper $Host;
	clean_kh_helper $IPAddress;
}

clean_kh() # Clean localhost known hosts for TargetHost
{	
	TargetHost=$1;
        (clean_known_hosts2 $TargetHost 2>&1) > /dev/null;
#        clean_known_hosts2 $SSHServer;
}
                                

clean_khs()
{
#	set -x;
        ClientHost=$SSHServer;

	        if [ "$ClientHost" = "localhost" ]; then
                {
        		for H in $TargetHosts; do
		        {       
        		        clean_kh $H;
        		} done;
                }   
                else
                {
                	set -x;
                	Cmd="/utils/sec/ssh/keys.sh --action clean_khs --host localhost --target \"$TargetHosts\"";
                	if [ -n $SwitchUser ]; then
                		#SSHCmd="ssh $SSHUser@$ClientHost";
                		Cmd="su -lc '$Cmd' $SwitchUser";
#                	else
#                		SSHCmd=$Cmd;
                	fi;
                	ssh $ClientHost $Cmd;
#                	$SSHCmd;
		}
		fi;                                                                                        
}
                                                                

install()
{
	ssh $SSHServer "mkdir -p $UtilPath/ /var/log/ssh/ /root/.ssh/;";
	/utils/rsync.sh data $UtilPath/ $SSHServer:$UtilPath/;
#	/utils/rsync.sh data /utils/ssh/keys_helper.pl $SSHServer:/utils/ssh/;
#	/utils/rsync.sh data /utils/ssh/log_session.sh $SSHServer:/utils/ssh/;
}

prepare_server_mini() # reduced version for remote only hosts
{
	ssh $SSHServer "mkdir -p $UtilPath/ /var/log/ssh/ /root/.ssh/;";
	/utils/rsync.sh data $UtilPath/update_authorized_key.sh $SSHServer:$UtilPath/;
	/utils/rsync.sh data $UtilPath/log_session.sh $SSHServer:$UtilPath/;
}

prepare_client_full() # for local clients
{
	ssh $SSHServer "mkdir -p $UtilPath";
	ssh -t $SSHServer "
		if ! dpkg -al | grep libshell-perl; then
			apt-get install libshell-perl;
		fi;
	";
	/utils/rsync.sh data $UtilPath/ $SSHServer:$UtilPath/;
	/utils/rsync.sh data /utils/dev/bashopts.sh $SSHServer:/utils/dev/;
	
	ssh $SSHServer "
		chmod 777 /utils/sec/ssh/keys.sh;
		chmod 777 /utils/sec/ssh;
		chmod 777 /utils/sec;
		chmod 777 /utils;
	";
	
	
}

renew_server()
{
#	SSHServer=$1;
#	KeySlotN=$2;
	echo -e "============== $SSHServer renew started ==============";
	$UtilPath/keys.sh --action gen_server --host $SSHServer;
	$UtilPath/keys.sh --action link $SSHServer --host $KeySlotN;
	echo -e "============== $SSHServer renew completed ==============\n";
}

test_protocol()
{	
	Find=$1;
	
	if ! cat /tmp/ssh_debug1.log | grep "$Find"; then
	{
		echo "Trying to find: $Find";
		echo "ERROR! Incorrect:";
                cat /tmp/ssh_debug1.log | grep "$Find";
                return 1;
        } fi;
        return 0;
} 

debug()
{
	Message=$@;
      	echo ===================================TEST!!!!
      	echo === Message: $Message;
      	exit;
}

show_ak()
{
	Host=$1;
	echo "========== $Host AKs:"
        ssh $Host "cat /root/.ssh/authorized_keys2";
        echo;
}                                                        
                                                        

case $Action in

# Example: ./keys.sh --action show_ak --host vps1
( show_ak )
	show_ak $SSHServer;
;;

# Example: ./keys.sh --action show_aks --host "vps1 vps3"
( show_aks )
	Hosts=$SSHServer;
	for H in $Hosts; do
	{
		show_ak $H;
	}
        done;
;;

#Example: ./keys.sh --action show_ck --slot 59
( show_ck )
	echo "========== Local Client Key Slot N: $KeySlotN";
#	set -x;
	cat /root/.ssh/keys/$KeySlotN/client_key_prev.pub;
	cat /root/.ssh/keys/$KeySlotN/client_key.pub;
#	set +x;
	echo;
;;

# Example: ./keys.sh --action gen_server --host vps3
( gen_server )
	set -x;
	
	# Replace server keys
#	ssh $SSHServer "rm -f /etc/ssh/ssh_host_*_key; (ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa -b 4096; ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa; ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa;)"; 
	
	if ssh $SSHServer "rm -f /etc/ssh/ssh_host_*_key; ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519 || ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N ''"; then
	{
		
		echo "=== Above is a NEW KEY!";
		#| grep Generating; 
	
		# Clean old server's public key from known_hosts to avoid "wrong host key" warnings
		clean_kh $SSHServer;
		
		ssh $SSHServer "service ssh restart; sync";
		
		ssh $SSHServer "echo test ssh connection using new server keys passed fine.";
	} fi;
	
;;

( gen_client )
	# Generate local keys here
#	KeySlotN=$2;
	NewKeyFullFileName=$KeySlotDir/$KeySlotN/$KeyFileName"_"$(date +\%Y_\%m_\%d__\%H_\%M_\%S);

	#Symlinks
	KeyFullFileNameSymLink=$KeySlotDir/$KeySlotN/$KeyFileName;
	PrevKeyFullFileNameSymLink=$KeySlotDir/$KeySlotN/client_key_prev;

	# Switch current symlink to prev symlink
	if [ -e $KeyFullFileNameSymLink ]; then
	{
		if ls -Fal $KeyFullFileNameSymLink  | grep -e '->'; then
		{	
			CurrentKeyFullFileName=`readlink -f $KeyFullFileNameSymLink`;
		}
		else
		{	
			CurrentKeyFullFileName=$KeyFullFileNameSymLink;
			mv $CurrentKeyFullFileName $CurrentKeyFullFileName.bak;
			mv $CurrentKeyFullFileName.pub $CurrentKeyFullFileName.bak.pub;
			CurrentKeyFullFileName=$CurrentKeyFullFileName.bak;
		} fi;
			
		ln -s -f $CurrentKeyFullFileName $PrevKeyFullFileNameSymLink;
		ln -s -f $CurrentKeyFullFileName.pub $PrevKeyFullFileNameSymLink.pub;
	}
	fi;
	
	if [ -e $NewKeyFullFileName ]; then # Imposible now when slot N is not changed on key renew
	{
		echo "Client key slot: $KeySlotN already exists, new client key generation skipped, old client key will be left intact and used.";
	} 
	else
	{
		if ! [ -d $KeySlotDir/$KeySlotN ]; then
		{
			mkdir "$KeySlotDir/$KeySlotN";
		}
		fi;
#		ssh-keygen -f $FullKeyFileName -N '' -t rsa -b 4096; #| grep Generating;
#		ssh-keygen -f $FullKeyFileName -N '' -t dsa; #| grep Generating;

# RSA key lenght may vary: 4096	8192 16384

		ssh-keygen -f $NewKeyFullFileName -N '' -t ed25519; #| grep Generating;
		ln -s -f $NewKeyFullFileName $KeyFullFileNameSymLink;
		ln -s -f $NewKeyFullFileName.pub $KeyFullFileNameSymLink.pub;
	
	

		chmod -R 700 "$KeySlotDir/$KeySlotN";
	} fi;
;;

( show_slots )
	ls -al $KeySlotDir/;
;;

( fingerprint )
	SSHServer=$2;
	#ssh-keygen -lf $KeySlotDir/$KeySlotN/$KeyFileName;
	ssh $SSHServer ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key;
;;


# Example: ./keys.sh --action verify --host vps3
( verify )
#set -x;
	echo $SSHServer;

	ssh -v $SSHServer exit 2>/tmp/ssh_debug1.log;
	if \

		test_protocol "server->client" && \
		test_protocol "server->client chacha20-poly1305@openssh.com" && \
		test_protocol "client->server" && \
		test_protocol "client->server chacha20-poly1305@openssh.com" && \
#		(test_protocol "Server host key:" | grep -v 25519 || test_protocol "Server host key: ED25519" ) && \
		test_protocol "Server host key:" && \
		test_protocol "Offering";
#		test_protocol "Offering ED25519 public key";
	then
		echo; echo "All tests passed.";
	else
		echo; echo "Some tests failed!";
	fi;
;;



# Example: ./keys.sh --action status --host vps3
( status )
#	set -x;
# ssh-keyscan

	heading "Local Client Config:";
       	cat /etc/ssh/ssh_config;

	heading "Remote Server Config:";
	ssh -q $SSHServer "cat /etc/ssh/sshd_config";

	heading "Remote Server Host Keys (Server Private Parts - only HASH - 	remote:ssh-keygen -lf):";
	ssh -q $SSHServer "ssh-keygen -lf /etc/ssh/ssh_host_rsa_key; true";
	ssh -q $SSHServer "ssh-keygen -lf /etc/ssh/ssh_host_dsa_key; true";
	ssh -q $SSHServer "ssh-keygen -lf /etc/ssh/ssh_host_ecdsa_key; true";
	ssh -q $SSHServer "ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key; true";
	
	heading "SHALL BE THE SAME AS ABOVE! - Locally Known about Remote Server Public Parts ( local:~/.ssh/known_hosts):";
	ssh-keygen -l -f ~/.ssh/known_hosts | grep -i $SSHServer;
		
	heading "Live Online Channel Keys - extracted from current session:";
	ssh -qv $SSHServer exit 2>/tmp/ssh_debug1.log;
	test_protocol "server->client";
	test_protocol "client->server";
	test_protocol "Server host key:";
	test_protocol "Offering";
	
	heading "Authorized Local Client Keys on the Remote Server (Client Public Parts - remote:/root/.ssh/authorized_keys*):";
	ssh -q $SSHServer "cat /root/.ssh/authorized_keys /root/.ssh/authorized_keys2; true";
	
	
;;

( verify_sk )
	SK_from_server=`ssh $SSHServer ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key | /utils/text/at_position.sh 2`;
	SK_from_client=`ssh-keygen -l -f ~/.ssh/known_hosts | grep -i "$SSHServer]" | /utils/text/at_position.sh 2`;

	echo -e "Server reported SK: $SK_from_server\nClient reported SK: $SK_from_client";
	if [ "$SK_from_server" == "$SK_from_client" ]; then
	{
		echo "SK verification passed.";
		exit 0;
	}
	else
	{
		echo "SK verification failed.";
		exit 1;
	} fi;
;;

( verify_ck )
#	set -x;

	ssh -v $SSHServer exit 2>/tmp/ssh_debug1.log;
	CK_from_server=`
		ssh $SSHServer "cat /root/.ssh/authorized_keys2 | grep $HOSTNAME | tail -n 1 > /tmp/authorized_keys2;
		ssh-keygen -l -f /tmp/authorized_keys2 | /utils/text/at_position.sh 2;
	"`;
	
#	CK_from_server=`ssh $SSHServer "ssh-keygen -lf /root/.ssh/authorized_keys2" | /utils/text/at_position.sh 2`;

	ClientKey=`test_protocol "identity file" | grep "client_key type 4" | /utils/text/at_position.sh 4`;
	CK_from_client=`ssh-keygen -lf $ClientKey | /utils/text/at_position.sh 2`;
	

	echo -e "Server reported CK: $CK_from_server\nClient reported CK: $CK_from_client";
	if [ "$CK_from_server" == "$CK_from_client" ]; then
	{
		echo "CK verification passed.";
		exit 0;
	}
	else
	{
		echo "CK verification failed.";
		exit 1;
	} fi;
;;

( verify_pair )
	/utils/sec/ssh/keys.sh --action verify_ck --host $SSHServer && \
        /utils/sec/ssh/keys.sh --action verify_sk --host $SSHServer;
        exit $?;
;;

# Updates remote SSH server slot
( link )
#set -x;

#	debug_args;
#	exit;

	ActualFileName=`readlink -f $KeySlotDir/$KeySlotN/$KeyFileName.pub`;
	/utils/rsync.sh data $ActualFileName $SSHServer:/tmp/client_key.pub;
	ssh $SSHServer "/utils/sec/ssh/update_authorized_key.sh \
		$HOSTNAME $KeySlotN $ShallLogSessions $ShallCleanOldAK $KeepAKs $ShallCleanAllAK";

##	use_slot; # unused now because slot number is not changed on key refresh

	clean_kh $SSHServer;
	ssh $SSHServer "echo ssh connection test to $SSHServer using new keys client passed fine.";
;;


( refresh_key ) # Regenerate client key and relink it to the server 
      #/utils/sec/ssh/keys.sh --action prep_server $Host; # updates corresponding server side script
 
      if [ "$ShallKeepClientKey" = "false" ]; then
      {
# 	debug refresh_key;
      	$UtilPath/keys.sh --action gen_client --slot $KeySlotN;
      } fi;
      
#set -x;
#      $UtilPath/keys.sh --action link --host $SSHServer --slot $KeySlotN;
      $UtilPath/keys.sh --action link $CmdArgs;
;;

( use_slot | install | copyright | clean_khs )
#	SSHServer=$2;
#	KeySlotN=$3;
	$Action;
;;

( clean_kh )
	clean_kh $SSHServer;
;;

( prep_server )
	prepare_server_mini;
;;	

( prep_client )
	prepare_client_full;
;;

( nothing )
	# it is included;
;;

esac;
