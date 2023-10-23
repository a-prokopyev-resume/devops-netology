#set -x;

source lib.sh;

Action=$1;

MoreArgs="${@:2}";

echo -e "\n\n\n===> Debug at $(date):";
case $Action in
	( start )
		Services="$MoreArgs";
		(set -x; docker-compose $Env up -d $Services);
#		Containers=$(docker-compose $Env up -d $Services | xargs);
#		for C in $Containers; do
#			docker inspect $C | grep -i env -A 10;
#		done;		
	;;

	( stop )
		Services="$MoreArgs";
		(set -x; docker-compose $Env stop $Services);
	;;

	( clean )
		/utils/docker/clean_stopped.sh;
	;;

	( inspect )
		Containers="$MoreArgs";
		for C in $Containers; do
			(set -x; docker inspect $C) | grep -i env -A 10;
		done;
	;;
esac;
docker ps -a;
