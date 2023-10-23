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

DBMS=$1; # lite | pg | my | elastic | mongo
Container=$2;
Action=$3; # cmd | sql_file | backup | restore | shell
ScriptDir="$(dirname "$(readlink -f "$0")")";
ConnectionEnvFile=${4:-$ScriptDir/docker-compose.env};
SQLTextFile="/tmp/dbms_resulting.sql";

if [ -z "$Container" ]; then
	case $DBMS in
	        ( lite )
	        	Container="SQLite";
	        ;;

	        ( pg )
	        	Container="PostgreSQL";
        	;;

	        ( my )
		        Container="MySQL";
        	;;

	        ( elastic )
	        	Container="ElasticSearch";
        	;;

	        ( mongo )
	        	Container="MongoDB";
        	;;
        	
        	( * )
        		echo "Error: unknown DBMS: $DBMS !";
        		exit 1;
        	;;
	esac;
fi;

pg_cmd()
{
	(
		source $ConnectionEnvFile;
		docker exec -it $Container psql -U $DB_USER -d $DB_NAME -c "$Cmd";
	)
}

pg_sql_file()
{
	(

		source $ConnectionEnvFile;
		cat $SQLTextFile | docker exec -i $Container psql -U $DB_USER -d $DB_NAME #docker exec -it PostgreSQL psql -U $DB_USER -d $DB_NAME -f "$SQLScriptFile";
	);
}

pg_create_db()
{
	(
                source $ConnectionEnvFile;
                echo -e "\n\n\n===> Create database:";
                ( 
                        set -x; 
                        docker exec -it $Container createdb -U $DB_USER $NewDBName;
                );
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
		source $ConnectionEnvFile;
		(
			set -x;
			docker exec -it $Container bash -lc "
				pg_dumpall --globals-only -U $DB_USER > /mnt/backup/$BackupFile.dumpall_globals;
				pg_dump --column-inserts --format=custom -U $DB_USER -d $DB_NAME > /mnt/backup/$BackupFile.pg_restore
			";
		)
	)
}

pg_restore_custom()
{
	(
		source $ConnectionEnvFile;
		( 
			set -x; 
			docker exec -it $Container bash -lc "
				psql -U $DB_USER -d $DB_NAME < /mnt/backup/$BackupFile.dumpall_globals;
				pg_restore $RestoreOptions --verbose -U $DB_USER --dbname=$DB_NAME /mnt/backup/$BackupFile.pg_restore
			";
		);
	)
}

pg_wait_ready()
{
       (
                source $ConnectionEnvFile;
                ( 
#                        set -x; 
                        docker exec -it $Container bash -lc "
                        	while ! pg_isready; do
                        		sleep 1s;
                        		echo ' ... waiting 1s ... ';
                        	done;
                        ";
                );
        );
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

case $Action in
        ( cmd )
        	Cmd=$5;
        	echo -e "\n\n\n===> Command text at $(date):";
		echo "$Cmd";
		echo -e "\n===> DBMS response at $(date):";
		$DBMS"_"$Action;
        ;;

        ( sql_file )
	        SQLFile="$5";
		SQLEnvFile="$6";
		if [ -z "$SQLEnvFile" ]; then
			SQLEnvFile=$ConnectionEnvFile;
		fi;
		echo -e "\n\n\n===> SQL query text at $(date):";
		(eval $(cat $SQLEnvFile | xargs) envsubst < $SQLFile) > $SQLTextFile;
		cat $SQLTextFile;
		echo -e "\n===> DBMS response at $(date):";
		$DBMS"_"$Action;
		rm -f $SQLTextFile;
	;;

	( create_db )
		NewDBName="$5";
		$DBMS"_"$Action; 
	;;

        ( backup )
        	BackupFile="$5";
		echo -e "\n\n\n===> Backup at $(date):";         	
		$DBMS"_"$Action;
        ;;

        ( restore )
	        BackupFile="$5";
	        RestoreOptions="${@:6}";
	        echo -e "\n\n\n===> Restore at $(date):";
		pg_restore_custom; # command $DBMS"_"$Action;
        ;;

        ( shell )
        	docker exec -it $Container bash -l;
        ;;
        
        ( wait_ready )
                echo -e "\n\n\n===> Waiting DBMS to start at $(date):";
        	$DBMS"_"$Action;
        ;;
        
        ( * )
                echo "Error: unknown Action: $Action !";
	        exit 2;
        ;;
esac;
