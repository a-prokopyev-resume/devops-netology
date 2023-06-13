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

import argparse;
import json, ruamel.yaml;
import sys;

parser = argparse.ArgumentParser(description="Python Homework 04-script-04-yaml",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter);
parser.add_argument("--to",  help="Specify: json or yaml.");
parser.add_argument("--source",  help="Specify input file.");
parser.add_argument("--destination",  help="Specify output file.");
args = vars(parser.parse_args());

SourceFile=args["source"];
if not SourceFile is None:
  try:
    Y = ruamel.yaml.YAML(typ='safe');
    SF=open(SourceFile);
    Data = Y.load(SF);
  except:
    print("Error: Could not open input file specified by --source option!");
    exit(1);

DestinationFile=args["destination"];
global DF;
if DestinationFile is None:
   DF=sys.stdout; 
else:
  DF=open(DestinationFile,'w');
  
if args["to"] == "json":
  json.dump(Data, DF, indent=2);
elif args["to"] == "yaml":
  Y.dump(Data,DF);
# sys.stdout.flush();
else:
  print("Error: Incorrect --to parameter for conversion destination format!");
  exit(2);
