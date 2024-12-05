#!/bin/bash

#===== The beginning of the Copyright Notice =====
copyright()
{

echo -e "
'============================== The Beginning of the Copyright Notice ==========================================================
' The AUTHOR of this file is Alexander Borisovich Prokopyev born on December 20, 1977 resident of the city of Kurgan, Russia;
' Series and Russian passport number (only the last two digits for each one): **22-****91
' Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
' Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
' Copyright (C) Alexander B. Prokopyev, 2023, All Rights Reserved.
' Contact:      a.prokopyev.resume at gmail dot com
'
' All source code contained in this file is protected by copyright law.
' This file is available under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
' PROVIDED FOLLOWING RESTRICTIONS APPLY:
' Nobody except the AUTHOR may alter or remove this copyright notice from any legal copies of this file content.
' Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
' \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
' specific language governing permissions and limitations under the License.
'
' ATTENTION: If your country laws are not compatible or collide with this license terms you are prohibited to use this content.
'================================= The End of the Copyright Notice =============================================================
";

}
#===== The end of the Copyright Notice =====

set -x;

Hosts="173.194.222.113 192.168.0.1 87.250.250.242";
Port=80;

Options=" --connect-timeout 3  --max-time 4 ";

check_availability()
{
	Address=$1;
	Times=${2:-1};
	for ((i=1; i<=Times; i++)); # || Times==0
	do
		rm -f good_pass.log; rm -f bad_pass.log;
		#timeout 3s 
		curl -v $Options --output good_pass.log --stderr bad_pass.log http://$Address:$Port; # 2>&1 >> output.log;
		Result=$?;
		cat good_pass.log >> good_output.log; cat bad_pass.log >> error_output.log;
		echo -ne "$(date) :   \t" >> log;
		if ((Result == 0 )); then
			echo "Test N:$i of address $Address passed. Exit code: $Result" >> log;
		else
			echo "Test N:$i of address $Address failed. Exit code: $Result" >> log;
			if ((Times==1)); then
				return 1;
			fi;
		fi;
	done;
}

#for H in $Hosts; do
#	check_availability $H 5;
#done;

for H in $Hosts; do
	check_availability $H;
	Result2=$?;
	if (( $Result2 == 1 )); then
       		echo "Check failed, exiting ...";
       		exit 1;
       	fi;
done;

#while check_availability "192.168.0.1" && check_availability "173.194.222.113" && check_availability "87.250.250.242"; do
#	echo "Checking ..."; 
#done;