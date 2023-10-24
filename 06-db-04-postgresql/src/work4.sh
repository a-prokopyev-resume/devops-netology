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

TestDumpFile="test_dump.sql";
HostBackupDir=$( src_env docker-compose; echo -n $HOST_BACKUP_DIR);

describe_cmd()
{
	local Cmd=$1;
	local Description=$2;
	echo "=====> $Description:";
	./dbms.sh pg1 cmd super $Cmd;
#	(
#		src_env super;
#		./dbms.sh pg1 shell_cmd super psql -U $DB_USER -c $Cmd;
#	)
}

show_db_objects()
{
	describe_cmd "\?" "Вывод списка команд"; #	./dbms.sh pg1 shell_cmd super psql --help=commands;
	describe_cmd "\l+" "Список баз данных";
	describe_cmd "\conninfo" "Информация о подключении";
	describe_cmd "\dtS" "Список таблиц";
	describe_cmd "\dS+" "Описание содержимого таблиц";
	describe_cmd "\q" "Выход из psql";
}

task1()
{
	./dbms.sh pg1 wipe;
	./dbms.sh pg1 start;
	./dbms.sh pg1 inspect;
        ./dbms.sh pg1 wait_ready;
	show_db_objects;
}

task2()
{
	./dbms.sh pg1 cmd super "CREATE DATABASE test_database";

	wget --output-document=$HostBackupDir/$TestDumpFile  https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-04-postgresql/test_data/test_dump.sql;
	./dbms.sh pg1 cmd2 admin -f /mnt/backup/$TestDumpFile;
	./dbms.sh pg1 cmd admin "\dt";
	./dbms.sh pg1 cmd admin "ANALYZE VERBOSE public.orders;"
	./dbms.sh pg1 cmd admin "SELECT avg_width FROM pg_stats WHERE tablename="\'orders\';
}

task3()
{
	./dbms.sh pg1 sql_file admin task3.sql;
}

task4()
{
	./dbms.sh pg backup admin backup2;
	echo "ALTER TABLE ORDERS ADD CONSTRAINT orders_tilte_unique UNIQUE (title);" >> $HostBackupDir/backup2.psql;
}

task1;
task2;
task3;
task4;
