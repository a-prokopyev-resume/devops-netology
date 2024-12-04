#!/usr/bin/env bash

# The Authour of this script is Alexander Borisovich Prokopyev ( a.prokopyev.resume@gmail.com ), 2024
# CV: https://2ly.link/21Xii
# If more test processes are running then only first one is taken from the list

set -x;

LogFile="/var/log/monitoring.log";
API_URL="https://test.com/monitoring/test/api";
DefaultProcessName="test2";
ProcessFirstStartTime=0; # never set to actual value yet
FirstStartTimeFile="/tmp/ProcessFirstStartTime.txt";

write_to_log()
{
	Message="$1";
	echo "$(date): $Message" >> $LogFile;
}

call_api()
{
	if ! timeout 3s curl "$API_URL" 2>&1 | cat >> /dev/null; then
		write_to_log "Cannot reach API server";
	fi;
}

get_process_start_time()
{
	local ProcessName="${1:-$DefaultProcessName}";
	local PId=$(ps -C "$ProcessName" -o pid=);
	local StartTime=0;
	if [ -n "$PId" ] && [ -f "/proc/$PId/stat" ]; then
		StartTime=$(awk '{print $22}' /proc/$PID/stat);
	else
		StartTime=1; # Process not running now
#		return 1;
	fi;
	echo $StartTime;
}	

process_has_been_restarted()
{
	local StartTime=$(get_process_start_time);
	if [ -f $FirstStartTimeFile ]; then
		ProcessFirstStartTime=$(cat $FirstStartTimeFile);
	fi;
	# $ProcessFirstStartTime not set yet and process running
	if ([ $ProcessFirstStartTime -eq 0 ]) && [ ! $StartTime -eq 1 ]; then # [ -z "$ProcessFirstStartTime" ] || 
		ProcessFirstStartTime=$StartTime;
		echo -n $ProcessFirstStartTime > $FirstStartTimeFile;
		return 2; # Process started for the first time yet
	fi;
	
	# If process is  missing
	if [ $StartTime -eq 1 ]; then
		return 1;
	else
		# Current process $StartTime is the same as first time; 
		if [ $ProcessFirstStartTime -eq $StartTime ]; then
			return 3; # It is the first process start
		else
			return 0; # Process has been restarted
		fi;		
	fi;
}

main()
{
	if ps -C "$DefaultProcessName"; then
		call_api;
	fi;
	if process_has_been_restarted; then
		StartTime=$(get_process_start_time);
		if ! grep $StartTime $LogFile; then # not written this restart yet
			write_to_log "Process test has been restarted with new start time: $StartTime";
		fi;
	fi;
}

main;

