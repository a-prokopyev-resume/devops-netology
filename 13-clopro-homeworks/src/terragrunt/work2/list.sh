set -x;

yc compute instance-group list;
yc compute instance list;
yc vpc network list;
yc vpc subnet list;
yc storage bucket list;
yc load-balancer target-group list;

TargetGroupId=$(yc load-balancer target-group list --format json | /utils/iac/bin/jq_static -r '.[].id');
yc load-balancer network-load-balancer target-states --name work2-lb --target-group-id $TargetGroupId;
yc load-balancer network-load-balancer list;
yc load-balancer network-load-balancer get work2-lb;
yc load-balancer target-group get work2-tg;




