# '============================== The Beginning of the Copyright Notice ==========================================================
# ' The AUTHOR of this file is Alexander Borisovich Prokopyev born on December 20, 1977 resident of the city of Kurgan, Russia;
# ' Series and Russian passport number (only the last two digits for each one): **22-****91
# ' Russian Individual Taxpayer Number of the AUTHOR (only the last four digits): ********2007
# ' Russian Insurance Number of Individual Ledger Account of the AUTHOR (only the last five digits): ***-***-859 04
# ' Copyright (C) Alexander B. Prokopyev, 2023, All Rights Reserved.
# ' Contact:      a.prokopyev.resume at gmail dot com
# '
# ' All source code contained in this file is protected by copyright law.
# ' This file is available under AGPL v3 (GNU Affero General Public License): https://www.gnu.org/licenses/agpl-3.0.en.html
# ' PROVIDED FOLLOWING RESTRICTIONS APPLY:
# ' Nobody except the AUTHOR may alter or remove this copyright notice from any legal copies of this file content.
# ' Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
# ' \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# ' specific language governing permissions and limitations under the License.
# '
# ' ATTENTION: If your country laws are not compatible or collide with this license terms you are prohibited to use this content.
# '================================= The End of the Copyright Notice =============================================================

#set -x;

#Seq1=$(echo sd{a..z});
#Seq2=$(echo sd{a..z}{1..5});

try_to_save_luks()
{
	ID=$1;
	
	DevPath="/dev/disk/by-id/$ID";
	Result=1;
	if blkid $DevPath | grep --silent -i luks; then
		/utils/sec/backup_luks_header.sh $ID;
		Result=$?;
	fi;
	if (( $Result == 0 )); then
        	echo "Successfully saved $ID header";
        fi;
        return $Result;
}

for Dev in sd{a..z}; do
	DevPath="/dev/$Dev";
#	echo $Dev;
	if [ -a $DevPath ]; then
		DevID=$(ls -al /dev/disk/by-id/ | grep ata | grep -P "$Dev$" | /utils/text/at_position.sh 9);
		try_to_save_luks $DevID;
		for PartID in $DevID"-part"{1..5}; do
			PartPath=/dev/disk/by-id/$PartID;
			if [ -a $PartPath ]; then
				try_to_save_luks $PartID;
	        	fi;
		done;
	fi;
done;
