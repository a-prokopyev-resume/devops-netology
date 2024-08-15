
set -x;

ClusterConfigFile="yc-k0sctl-cluster.yml";

#cat $ClusterConfigFile | grep -v 'name: master' | grep -v 'name: worker' | /utils/k0s/bin/k0sctl-linux-x64-v0.18.1 apply --disable-telemetry --debug --config -;

#=== Good:

#/utils/k0s/bin/k0sctl-linux-x64-v0.18.1 reset --force --disable-telemetry --debug --trace --config $ClusterConfigFile; exit;

/utils/k0s/bin/k0sctl-linux-x64-v0.18.1 apply --concurrency 1 --disable-telemetry --debug --trace --config $ClusterConfigFile;

/utils/k0s/bin/k0sctl-linux-x64-v0.18.1 kubeconfig --config $ClusterConfigFile > yc-k0s-kubectl.yml