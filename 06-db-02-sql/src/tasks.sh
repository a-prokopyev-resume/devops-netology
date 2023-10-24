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

postgres_cmd()
{
	local Cmd=$1;
	ConnectionEnv=$2;
	./dbms.sh pg cmd "$ConnectionEnv" "$Cmd";
}

postgres_script()
{
        local SQLFile=$1;
        ConnectionEnv=$2;
        SQLEnv=$3;
        ./dbms.sh pg sql_file "$ConnectionEnv" "$SQLFile" "$SQLEnv";
}

show_db_objects()
{
	Container=$1;
	ConnectionEnv=$2;	
	./dbms.sh "$Container" cmd "$ConnectionEnv" "SELECT * FROM pg_database";
	./dbms.sh "$Container" cmd "$ConnectionEnv" '\l';
	./dbms.sh "$Container" cmd "$ConnectionEnv" '\dt';
	./dbms.sh "$Container" cmd "$ConnectionEnv" '\d+ Clients';
	./dbms.sh "$Container" cmd "$ConnectionEnv" '\d+ Orders';
	( 
		src_env $ConnectionEnv;
		./dbms.sh "$Container" cmd "$ConnectionEnv" "SELECT * FROM information_schema.table_privileges WHERE grantee<>'PUBLIC' and table_catalog="\'$DB_NAME\' ;
	);
}

# For debug only
clean_database1()
{
	(
		src_env admin;
		postgres_cmd "DROP DATABASE \"$DB_NAME\" ";
		postgres_cmd "DROP USER \"$DB_USER\" ";
	)
	(	
		src_env user;
		postgres_cmd "DROP USER \"$DB_USER\" ";
	);
}

task1()
{
#	clean_database1;
	./dbms.sh pg1 wipe;
	./dbms.sh pg1 start;
        ./dbms.sh pg1 wait_ready;
}

task2()
{
	postgres_script task2a.sql "" admin;

	(	
		src_env admin;
		if (  postgres_cmd "SELECT 1 FROM pg_database WHERE datname = "\'$DB_NAME\' | grep rows | grep -q 1); then
			echo "Database already exists";
		else
			postgres_cmd "CREATE DATABASE \"$DB_NAME\" ";
			postgres_cmd "GRANT ALL PRIVILEGES ON DATABASE \"$DB_NAME\" to \"$DB_USER\" WITH GRANT OPTION ";
		fi;
	);

	postgres_script task2b.sql admin user;
	show_db_objects pg admin;
}

task3()
{
	./dbms.sh pg sql_file user task3.sql;
}

task4()
{
	./dbms.sh pg sql_file user task4.sql;
}

task5()
{
	./dbms.sh pg sql_file user task5.sql;
}

task6()
{
	BackupFile="backup11";

	./dbms.sh pg1 start;
	./dbms.sh pg1 inspect;
	./dbms.sh pg backup super1 $BackupFile;
#	./dbms.sh pg1 stop;

	./dbms.sh pg2 wipe;
	./dbms.sh pg2 start super2;
	./dbms.sh pg2 inspect;
	./dbms.sh pg2 wait_ready;
	./dbms.sh pg2 create_db super2 "test-db2";
	./dbms.sh pg2 restore super2 $BackupFile; # --no-owner; # --create
	show_db_objects pg2 admin2;
}

task1;
task2;
task3;
task4;
task5;
task6;

./dbms.sh pg1 wipe;
./dbms.sh pg2 wipe;

# Its is better to place information about expected container into an environment file later?