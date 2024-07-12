k0s stop;
/etc/init.d/k0scontroller stop;
killall /var/lib/k0s/bin/containerd-shim-runc-v2  kube-proxy pause coredns kube-router;
#./umount.sh k0s;
