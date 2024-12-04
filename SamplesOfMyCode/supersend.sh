#!/bin/bash

# ===========================================================================================================================================
# Copyright (C) Alexander B. Prokopyev, 2015-2016
# ===========================================================================================================================================

ShallDebug="no" # yes or no 

debug_on()
{
	if [ "$ShallDebug" == "yes" ]; then
	{
		set -x;
	}
	else
	{
		set +x;
	}
	fi;
}

debug_off()     
{ 
	set +x;
}

run_cmd()
{

	Cmd=$1;
	Host=$2;	
	
	if [ -n "$Host" ]; then
	{
		ssh $Host "$Cmd";
		return $?;
	}
	else
	{
		$Cmd;
		return $?;
	}
	fi;
}

get_part()
{
	Resource=$1;
	Part=$2;
	echo "$Resource" | perl -ne 'my $S=$_; $S =~ s/^((?<Host>.*?):\/){0,1}(?<Pool>.*?)\/(?<DataSet>.*?)$/$+{'$Part'}/; print "$S";';
}


get_host()
{
	Resource=$1;
	get_part $Resource "Host";
}

get_pool()
{

	Resource=$1;
	get_part $Resource "Pool";
}

get_ds()
{

	Resource=$1;
	get_part $Resource "DataSet";
}


shift_last()
{

	Pool=$1;
	DS=$2;
	Date=$3;
	Host=$4;

	debug_on;
	run_cmd "zfs destroy $Pool/$DS@last" $Host;
	run_cmd "zfs rename $Pool/$DS@$Date $Pool/$DS@last" $Host;
	debug_off;
	
}

AreYouSure()                                                                                                                                       
{                                                                                                                                                           
	Text=$1;

        dialog --yesno "$Text \n Are you sure? Please confirm:" 10 120;
        Result=$?;
        
        clear;
        
        return $Result;
}           


incremental_send_to()
{
	FromSnapshot=$1;
	ToSnapshot=$2;
	echo "=== Sending incremental since snapshot: $FromSnapshot";
#	if [ "$FromSnapshot"=="first" ]; then
#		run_cmd "zfs rollback -r $ToPool/$ToDS@last" $ToHost;
#	else

		if ! run_cmd "zfs rollback $ToPool/$ToDS@$FromSnapshot" $ToHost; then
		{
#set -x;			
# Snapshot exists?
			if run_cmd "zfs list -t snapshot -r $ToPool/$ToDS" $ToHost | grep "@$FromSnapshot"; then 
			{
				if AreYouSure "Do you like to rollback destination to $ToPool/$ToDS@$FromSnapshot deleting all later snapshots?"; then
				{
					if ! run_cmd "zfs rollback -r $ToPool/$ToDS@$FromSnapshot" $ToHost; then
					{
						return 3;
					}
					fi;
					
				}
				else
				{
					return 8;
				} fi;
			} fi;
		} fi;
#	fi;
	set -x;
	run_cmd "zfs send -I @$FromSnapshot $FromPool/$FromDS@$ToSnapshot" $FromHost  | pv | run_cmd "zfs receive $ToPool/$ToDS" $ToHost;
	set +x;
	return $?;
}


incremental_send()
{
        FromSnapshot=$1;
        incremental_send_to $FromSnapshot $Date;
}

single_send()
{
	FromSnapshot=$1;
	echo "=== Sending single snapshot: "$FromSnapshot;
	run_cmd "zfs send $FromPool/$FromDS@$FromSnapshot" $FromHost  | pv | run_cmd "zfs receive -F $ToPool/$ToDS" $ToHost;
	return $?;
}

keep_n()
{

#set -x;

	Pool=$1;
	DS=$2;
	Options2=$3;
	Host=$4;

#	if [ "$Options" == "keep" ]; then
		KeepN=$Options2;
		NowN=`run_cmd "zfs list -t snapshot -r $Pool/$DS" $Host | grep --word-regexp "$Pool/$DS" | wc --lines`;
		if [ $NowN -le $KeepN ]; then
			echo;
		else
			# Hidden destroy here too
#			set -x;
#			echo $NowN;
#			echo $KeepN;
#set -x;
			run_cmd "/utils/fs/z/clean_snapshots.sh $Pool/$DS $[$NowN-$KeepN]" $Host 2> /dev/null;
		fi;
#		run_cmd "zfs snapshot $Pool/$DS@keep_$Date" $Host;
#	fi;
}

send_x()
{


#	echo $FromHost $FromPool $FromDS $ToHost $ToPool $ToDS; exit;

	


	Date=$(date +\%Y_\%m_\%d__\%H_\%M_\%S);

	if [ "$Options" == "clean" ]; then
		Options="keep";
		Options2="0";
	fi;


	
	if [ "$Options" == "keep" ]; then

#		set -x;
		keep_n  $FromPool $FromDS $Options2 $FromHost;
		keep_n  $ToPool $ToDS $Options2 $ToHost;	

#		KeepN=$Options2;
#		NowN=`run_cmd "zfs list -t snapshot" $FromHost | grep --word-regexp "$FromPool/$FromDS" | wc --lines`;
#		if [ $NowN -le $KeepN ]; then
#			echo;
#		else
#			# Hidden destroy here too
#			run_cmd "/utils/fs/z/clean_snapshots.sh $FromPool/$FromDS $[$NowN-$KeepN]" $FromHost 2> /dev/null;
#			run_cmd "/utils/fs/z/clean_snapshots.sh $ToPool/$ToDS $[$NowN-$KeepN]" $ToHost 2> /dev/null;
#		fi;
		run_cmd "zfs snapshot $FromPool/$FromDS@keep_$Date" $FromHost;
	fi;
	
	
#!!!  	if ! [ "$Options" == "no_modify" ]; then
#        {   
		run_cmd "zfs snapshot $FromPool/$FromDS@$Date" $FromHost;
#	} fi;
	
	echo "=========== Sending $From@$Date to $To:";


	if run_cmd "mount" $ToHost | grep $ToPool/$ToDS; then
		run_cmd "umount $ToPool/$ToDS" $ToHost;
	fi;
	

#!!!	if [ "$Options" == "no_modify" ]; then
#	{
#		echo "no yet";
#	}
#	else
#	{
		if incremental_send "last"; then
		{
			echo "incremental_send last - success!";
		}
		else
		{
			if !(incremental_send "first"); then
			{
				if single_send "first"; then
					if !(incremental_send "first"); then
					{
						echo "Error2 !!!";
						exit 2;
					}
					fi;
				else
				{
					echo "Error1 !!!";
					exit 1;
				} fi;
			} fi;
		} fi;
#	} fi;



#!!! Later try to keep intermediate last by renaming it to last_no_modify or bookmarking with such name
# Then copy to third place (or second destination) starting from last_no_modify to avoid rolling back to the destination2@first
	if [ "$Options" == "no_modify" ]; then
	{
		echo "NO_SNAP mode! Deleting new snapshots on the both sides to keep them compatible with their other copies.";
		run_cmd "zfs destroy $FromPool/$FromDS@$Date" $FromHost;
		run_cmd "zfs destroy $ToPool/$ToDS@$Date" $ToHost;
	}
	else
	{
		shift_last $FromPool $FromDS $Date $FromHost;
		shift_last $ToPool $ToDS $Date $ToHost;	
	} fi;

	debug_off;

#	echo "=== Source snapshots:"
#	run_cmd "zfs list -t snapshot" $FromHost | grep "$FromPool/$FromDS";
#	echo "=== Destination snapshots:"
#	run_cmd "zfs list -t snapshot" $ToHost | grep "$ToPool/$ToDS";
}

snapshot_exists()
{
	Dataset=$1;
	Snapshot=$2;
	Host=$3;

	if run_cmd "zfs list -t snapshot -r $Dataset" $Host | grep "$Snapshot"; then
	{
		return 0;
	}
	else
	{
		echo "Error: cannot find snapshot: $Dataset@$Snapshot";
		return 1;
	} fi;
}

shift_first()
{
	ToSnapshot=$1;
	if (snapshot_exists  $FromPool/$FromDS $ToSnapshot $FromHost) && (snapshot_exists  $ToPool/$ToDS $ToSnapshot $ToHost); then
	{
		run_cmd "zfs rename $FromPool/$FromDS@first first_shifted_to_$ToSnapshot" $FromHost;
		run_cmd "zfs rename $ToPool/$ToDS@first first_shifted_to_$ToSnapshot" $ToHost;
		if \
			run_cmd "zfs rename $FromPool/$FromDS@$ToSnapshot first" $FromHost && \
			run_cmd "zfs rename $ToPool/$ToDS@$ToSnapshot first" $ToHost;
		then
		{
			return 0;
		}
		else
		{
			echo "ERROR: Failed during renaming, snapshot names may be in inconsistent state now!";
			return 3;
		} fi;
	}
	else
	{
		echo "Error: incorrect target ToSnapshot specified! Exiting without processing.";
		return 2;
	} fi;
}

From=$1;
To=$2;
Options=$3;
Options2=$4;

FromHost=`get_host $From`;
FromPool=`get_pool $From`;
FromDS=`get_ds $From`;

ToHost=`get_host $To`;
ToPool=`get_pool $To`;
ToDS=`get_ds $To`;

if [ -z $ToDS ]; then
	ToDS=$FromDS;
fi;

debug_on;

Action=$Options;

case $Action in
	( shift_first )
		ToSnapshot=$Options2;
		shift_first $ToSnapshot;
	;;
	( * )
		send_x $From $To;
	;;
esac;

exit $?;
