#!/usr/bin/env python3
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

import os,sys,socket;
import argparse;
import peewee,pickle;

parser = argparse.ArgumentParser(description="Python Homework 04-script-04-py",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter);
parser.add_argument("--action",  help="Specify: add or check.");
parser.add_argument("--hosts",  help="Specify host names delimited by commа to check.");
args = vars(parser.parse_args());


DB = peewee.SqliteDatabase("hosts.db");
HostDict = {};

def save_new_hosts():
  with open("hosts.json", "w") as J:
    json.dump(HostDict, J, indent=2);
  with open("hosts.yaml", "w") as Y:
    yaml.dump(HostDict, Y, explicit_start=True, explicit_end=True);

def InitDB():
    if __name__ == "__main__":
      try:
        Host.create_table();
#       DB.execute_sql("");
      except peewee.OperationalError:
        print("Hosts table already exists!");

class Host(peewee.Model):
    Name = peewee.CharField();
    IPAddress = peewee.CharField();
    @staticmethod
    def Add2(N, IP):
        NewHost=Host.create(Name=N, IPAddress=IP);
        NewHost.save();
    @staticmethod
    def Add(N):
        IP=socket.gethostbyname(N);
        try:
            Host.Add2(N,IP);
            print("Host " + N + ":" + IP + " saved to the database.");
        except:
            print("Could not save Host " + N + ":" + IP + " to the database, such pair already exists.");
    @staticmethod
    def FindSavedHosts(N):
        return Host.select().where(Host.Name == N);
    @staticmethod
    def Check(N):
        CurrentIP=socket.gethostbyname(N);
        HostDict[N] = CurrentIP;
        print("===> Checking earlier IP addresses for the \thost: " + N + " \t\tIP: " + CurrentIP);
        IsMismatchFound=False;
        SHs=Host.FindSavedHosts(N);
        for H in SHs:
          if H.IPAddress != CurrentIP:
#            print("\tIP mismatch for  host: " + N + "; \tsaved IP: " + H.IPAddress + " \tcurrent IP: " + CurrentIP);
            print("\tIP mismatch found - saved IP: " + H.IPAddress);
            IsMismatchFound=True;
        if not IsMismatchFound:
          print("\tNo IP mismatches");  
    class Meta:
        database = DB;
        #constraints = [SQL('UNIQUE (Name, IPAddress)')];
        indexes = ( (('Name', 'IPAddress'), True), );

Action=args["action"]; 
# match args["action"]: # syntax missing in Python v3.9.x
if Action == "init":
  InitDB();   
else:
  try:
    Hosts=args["hosts"].split(",");
  except:
    print("Error: specify --hosts parameter delimited by commas");
  if Action == "add":
    for H in Hosts:
      Host.Add(H);
  elif Action == "check":
    for H in Hosts:
      Host.Check(H);
        HostDict[N] = CurrentIP;
    save_new_hosts();
  else:
    print("Error: incorrent action specified!");

DB.close();
sys.exit(0);

#pickle.loads
#pickle.dumps
