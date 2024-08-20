source ssh_agent.sh
#ssh -A -t  $1 "ssh -t 192.168.20.20 bash -li";
ssh -A $1 'ssh 192.168.20.20 ping -c 3 ya.ru';


