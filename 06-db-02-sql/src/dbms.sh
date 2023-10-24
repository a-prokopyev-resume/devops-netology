#============================== The Beginning of the Copyright Notice ==========================================================
# The AUTHOR of this file and the owner of exclusive rights is Alexander Borisovich Prokopyev 
# born on December 20, 1977 resident of the city of Kurgan, Russia;
# Series and Russian passport number (only the last two digits for each one): **22-****91
# Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# Copyright (C) Alexander B. Prokopyev, 2023, All Rights Reserved.
# Contact:     a.prokopyev.resume at gmail dot com
#
# All source code contained in this file is protected by copyright law.
# This file is available under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
# PROVIDED FOLLOWING RESTRICTIONS APPLY:
# Nobody except the AUTHOR may alter or remove this copyright notice from any legal copies of this file content.
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# AS IS BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#================================= The End of the Copyright Notice =============================================================

#set -x;

source lib.sh;

#DBMS=$1; # lite | pg | my | elastic | mongo
Container=$1; # lite[N] | pg[N] | my[N] | elastic[N] | mongo[N]
#Container=$2;
Action=$2; # cmd | sql_file | backup | restore | shell
#ScriptDir="$(dirname "$(readlink -f "$0")")";
ConnectionEnv=${3:-super};
SQLTextFile="/tmp/dbms_resulting.sql";

if [ -z "$Container" ]; then
	echo 'Error: $Container parameter cannot be null!';
	exit 1;
fi;

LastChar=${Container: -1};
if echo -n "$LastChar" | grep -q -P "^[0-9]+$"; then # Is number
	DBMS=${Container:0:-1};
else
	DBMS=$Container;
	Container=$DBMS"1";
fi;

case $DBMS in
	( lite | pg | my | elastic | mongo )
#		echo "=> Database type: $DBMS";
        ;;
        ( * )
		echo "Error: unknown DBMS: $DBMS !";
                exit 2;
        ;;
esac;

#if [ -z "$Container" ]; then
#	Container=$DBMS"1";
#fi;
#if echo $Container | grep "^[0-9]+$"; then # Is number
#	Container=$DBMS$Container;
#fi;

#echo "=> Container (compose service): $Container";

src_connection_env()
{
	src_env $ConnectionEnv;
	echo "===| Response [DB: $DB_NAME; U: $DB_USER] at $(date):";
}

pg_cmd()
{
	(
		src_connection_env;
		docker exec -it $Container psql -U $DB_USER -d $DB_NAME -c "$Cmd";
	)
}

pg_sql_file()
{
	(
		src_connection_env;
		cat $SQLTextFile | docker exec -i $Container psql -U $DB_USER -d $DB_NAME #docker exec -it PostgreSQL psql -U $DB_USER -d $DB_NAME -f "$SQLScriptFile";
	);
}

pg_create_db()
{
	(
                src_connection_env;
                set -x; docker exec -it $Container createdb -U $DB_USER $NewDBName;
        )

#        if (  ./postgres_cmd.sh "SELECT 1 FROM pg_database WHERE datname = "\'$DB_NAME\' | grep rows | grep -q 1); then
#                echo "Database already exists";
#        else
#                ./postgres_cmd.sh "CREATE DATABASE \"$DB_NAME\" ";
#                ./postgres_cmd.sh "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" to \"$DB_USER\" WITH GRANT OPTION ";
#        fi;
}

pg_backup()
{
	(
		src_connection_env;
		set -x; docker exec -it $Container bash -lc "
			pg_dumpall --globals-only -U $DB_USER > /mnt/backup/$BackupFile.dumpall_globals;
			pg_dump --column-inserts --format=custom -U $DB_USER -d $DB_NAME > /mnt/backup/$BackupFile.pg_restore
		";
	)
}

pg_restore_custom()
{
	(
		src_connection_env;
		set -x; docker exec -it $Container bash -lc "
			psql -U $DB_USER -d $DB_NAME < /mnt/backup/$BackupFile.dumpall_globals;
			pg_restore $RestoreOptions --verbose -U $DB_USER --dbname=$DB_NAME /mnt/backup/$BackupFile.pg_restore
		";
	)
}

pg_wait_ready()
{
                docker exec -it $Container bash -lc "
                       	while ! pg_isready; do
                       		sleep 1s;
                       		echo ' ... waiting 1s ... ';
                     	done;
	        ";
      		sleep 10s;
}

my_cmd()
{
	echo "Not implemented yet!";
}


my_sql_file()
{
	echo "Not implemented yet!";
}

my_backup()
{
	echo "Not implemented yet!";
}

my_restore()
{
	echo "Not implemented yet!";
}

docker_inspect()
{
	local C=$1;
	(set -x; docker inspect $C) | grep -i env -A 10;
	docker ps -a;
}

docker_stop()
{
	local C=$1;
	(set -x; docker-compose $ComposeEnv stop $C);
}

docker_clean()
{
	/utils/docker/clean_stopped.sh;
}

echo -e "\n\n\n===> $Action(cont:=$Container, env:=$ConnectionEnv) at $(date):";

case $Action in
        ( cmd )
        	Cmd=$4;
		echo "$Cmd";
		$DBMS"_"$Action;
        ;;

        ( sql_file )
	        SQLFile="$4";
		SQLEnv="$5";
		if [ -z "$SQLEnv" ]; then
			SQLEnv=$ConnectionEnv;
		fi;
		SQLEnvFile=$(env_file $SQLEnv);
		(
			source $SQLEnvFile;
			echo "==> SQL interpolation using [ENV: $SQLEnv; DB_NAME: $DB_NAME; DB_USER: $DB_USER]";
		)
		(eval $(cat $SQLEnvFile | xargs) envsubst < $SQLFile) > $SQLTextFile;
		cat $SQLTextFile; echo;
		$DBMS"_"$Action;
		rm -f $SQLTextFile;
	;;

	( create_db )
		NewDBName="$4";
		$DBMS"_"$Action; 
	;;

        ( backup )
        	BackupFile="$4";
		$DBMS"_"$Action;
        ;;

        ( restore )
	        BackupFile="$4";
	        RestoreOptions="${@:6}";
		pg_restore_custom; # command $DBMS"_"$Action;
        ;;

        ( shell )
        	docker exec -it $Container bash -l;
        ;;
        
        ( wait_ready )
        	$DBMS"_"$Action;
        ;;

	( start )
		(set -x; docker-compose $ComposeEnv up -d $Container);
#		docker_inspect $Container;
	;;

	( stop )
		docker_stop $Container;
	;;

	( clean )
		/utils/docker/clean_stopped.sh;
	;;
	
	( wipe )
	        docker_stop $Container;
	        docker_clean;
	        sleep 1s;
	        rm -Rf dbms_data/$Container;
        	sleep 1s;
        ;;

	( inspect )
		docker_inspect $Container;
	;;        
        
        ( * )
                echo "Error: unknown Action: $Action !";
	        exit 3;
        ;;
esac;
