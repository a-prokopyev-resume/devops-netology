HostMessage=$(cat); 
( 
	echo "===> This is a reply from container C1";
	echo "The host has sent message: $HostMessage";
) | tee /data/reply_from_c1.txt;