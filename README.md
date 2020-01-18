# hetzner-cloud-init

This is a simple solution to a simple problem: when deploying Kubernetes to [Hetzner Cloud](https://www.hetzner.com/cloud) using [the node driver](https://github.com/mxschmitt/ui-driver-hetzner) for [Rancher](https://rancher.com/), no firewall is set up, leaving the Kubernetes services (including etcd) exposed. Unauthenticated access to such services is forbidden, but I prefer not to expose them anyway by using a firewall. This basic cloud init can be added to a node template created for the node driver and will set up a basic firewall with ufw (so Ubuntu is expected as the OS for the nodes) and fail2ban. Every minute, the firewall configuration will be updated by querying the Hetzner Cloud API so to take into account any changes to the cluster (after adding/removing nodes). NOTE: the node driver allows selecting a private network if configured in the Hetzner Cloud project, however due to a limitation with Docker Machine (which node drivers use behind the scenes) the communication between the nodes for the Kubernetes services actually goes through the public interface, effectively rendering the private network useless in this case. For this reason, besides the firewall setup I recommend selecting [Weave](https://www.weave.works/blog/cni-for-docker-containers/) as the network provider when creating the cluster with Rancher, so to enable encryption of all the traffic between the nodes.

To use this, just add this little YAML as cloud init config in the node template, specifying the Hetzner Cloud API token and a comma separated list of IPs that you want to whitelist in the firewall, so that you can connect to the cluster e.g. with kubectl.


```yaml
#cloud-config
locale: en_GB.UTF-8

runcmd:
  - curl -s https://raw.githubusercontent.com/vitobotta/hetzner-cloud-init/master/setup.sh | bash -s <TOKEN> <WHITELIST>
```