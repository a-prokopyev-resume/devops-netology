#!/bin/bash

MessageFile="$1";
echo -n "Message: "; cat $MessageFile;
echo -e "\nTesting ...";

if ! grep --silent --perl-regexp '^.{3,30}$' $MessageFile; then
	echo "Your message is too long";
	exit 1;	
fi;

if ! grep --silent --perl-regexp '^\[\d{1,2}-.{1,15}-\d{1,2}-.{1,15}\]\s.{1,25}$' $MessageFile; then
        echo "Your message does not match the pattern: [nn-xxx-nn-yyy] zzz";
        exit 2;
fi;

echo "Good commit message";
exit 0;