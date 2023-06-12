#!/usr/bin/env python3

import os;
import argparse;

parser = argparse.ArgumentParser(description="Python Homework 04-script-02-py",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter);
parser.add_argument("-p", "--path",  help="archive mode");
args = vars(parser.parse_args());
project_path=args["path"];
bash_command = ["cd " + project_path, "git status"];
result_os = os.popen(' && '.join(bash_command)).read();
#print(result_os);
#is_change = False; # unused
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '');
        print(prepare_result);
#        break;
        
