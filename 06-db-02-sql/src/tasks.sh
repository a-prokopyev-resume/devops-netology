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

postgres_cmd()
{
	local Cmd=$1;
	ConnectionEnv=$2;
	./dbms.sh pg "" cmd "$ConnectionEnv" "$Cmd";
}

postgres_script()
{
        local SQLFile=$1;
        ConnectionEnv=$2;
        SQLEnv=$3;
        ./dbms.sh pg "" sql_file "$ConnectionEnv" "$SQLFile" "$SQLEnv";
}

show_db_objects()
{
	ConnectionEnv=$1;
	Container=$2;
	
	./dbms.sh pg "$Container" cmd "$ConnectionEnv" "SELECT * FROM pg_database";
	./dbms.sh pg "$Container" cmd "$ConnectionEnv" '\l';
	./dbms.sh pg "$Container" cmd "$ConnectionEnv" '\dt';
	./dbms.sh pg "$Container" cmd "$ConnectionEnv" '\d+ Clients';
	./dbms.sh pg "$Container" cmd "$ConnectionEnv" '\d+ Orders';
	./dbms.sh pg "$Container" cmd "$ConnectionEnv" "SELECT * FROM information_schema.table_privileges WHERE grantee<>'PUBLIC' and table_catalog='test-db'";	
}

clean_service_state()
{
	Service=$1;
	./compose.sh stop $Service;
	./compose.sh clean;
	sleep 1s;
	rm -Rf dbms_data/$Service;
	sleep 1s;
}

# For debug only
clean_database1()
{
	(
		source admin.env;
		postgres_cmd "DROP DATABASE \"$DB_NAME\" ";
		postgres_cmd "DROP USER \"$DB_USER\" ";
	)
	(	
		source user.env;
		postgres_cmd "DROP USER \"$DB_USER\" ";
	);
}

task1()
{
#	clean_database1;
	clean_service_state postgres;
	./compose.sh start postgres;
        ./dbms.sh pg "" wait_ready;
#        sleep 10s;
}

task2()
{
	postgres_script task2a.sql docker-compose.env admin.env;

	(	
		source admin.env;
		if (  postgres_cmd "SELECT 1 FROM pg_database WHERE datname = "\'$DB_NAME\' | grep rows | grep -q 1); then
			echo "Database already exists";
		else
			postgres_cmd "CREATE DATABASE \"$DB_NAME\" ";
			postgres_cmd "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" to \"$DB_USER\" WITH GRANT OPTION ";
		fi;
	);

	postgres_script task2b.sql admin.env user.env;
	show_db_objects admin.env;
}

task3()
{
	./dbms.sh pg "" sql_file user.env task3.sql;
}

task4()
{
	./dbms.sh pg "" sql_file user.env task4.sql;
}

task5()
{
	./dbms.sh pg "" sql_file user.env task5.sql;
}

task6()
{
	BackupFile="backup8";

	./compose.sh start postgres;
	./compose.sh inspect PostgreSQL;
	./dbms.sh pg "" backup postgres.env $BackupFile;
	./compose.sh stop postgres;

	clean_service_state postgres2;
	./compose.sh start postgres2;
	./compose.sh inspect PostgreSQL2;
	./dbms.sh pg "PostgreSQL2" wait_ready;
	./dbms.sh pg "PostgreSQL2" create_db "" "test-db2";
	./dbms.sh pg "PostgreSQL2" restore "postgres2.env" $BackupFile; # --no-owner; # --create
	show_db_objects postgres2.env PostgreSQL2;

	clean_service_state postgres2;
}

task1;
task2;
task3;
task4;
task5;
task6;

clean_service_state postgres;

# Its is better to place information about expected container into an environment file later?