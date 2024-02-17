docker cp iac:/etc/hosts /tmp/;
echo >> /etc/hosts;
cat /tmp/hosts >> /etc/hosts;
