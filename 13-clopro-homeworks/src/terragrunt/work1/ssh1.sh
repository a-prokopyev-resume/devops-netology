source ssh_agent.sh
#ssh -A -t $1 "ssh -t  192.168.10.10 bash -li";
ssh -A $1 'ssh  192.168.10.10 bash -lc "route del default; route add default gw 192.168.10.254; route -n; ping -c 3 ya.ru"';
 

