#ANSIBLE_DISPLAY_FAILED_STDERR=0 

source lib.sh;

Action=$1;

# Convert all env/*.env to vars/*.env.json to later load them into Ansible playbook as variables

case $Action in
	( all )
		Options="";
	;;
	( v )
		#Options=" -vvvvv ";
	;;
	( recover )
		./wipe.sh;
	;;
	( * )
		Options=" --skip-tags task1 --skip-tags task2 "; # Why not count skips?
	;;
esac;

./compose.sh start my1 gui iac;

cd env; for E in $(ls *.env); do
#( set -x;	
(../env2json.py $E) > ../vars/$E.json; 
#);
done; cd ..;

#sleep 30s;
/utils/iac/ansible.sh playbook $Options play.yml;
#--extra-vars @vars/secrets.yml;

#mariadb -h my1 -P 3306 -u root -psuper