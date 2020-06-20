# hetzner-cloud-init

This is a simple solution to a couple of simple problems: 

* when deploying Kubernetes to [Hetzner Cloud](https://www.hetzner.com/cloud) using [the node driver](https://github.com/mxschmitt/ui-driver-hetzner) for [Rancher](https://rancher.com/), no firewall is set up, leaving the Kubernetes services (including etcd) exposed. Unauthenticated access to such services is forbidden, but I prefer not to expose them anyway by using a firewall. This basic cloud init can be added to a node template created for the node driver and will set up a basic firewall with ufw (so Ubuntu is expected as the OS for the nodes) and fail2ban. Every minute, the firewall configuration will be updated by querying the Hetzner Cloud API so to take into account any changes to the cluster (after adding/removing nodes). 
* I wanted the nodes of my cluster to automatically configure their public network interface with any floating IPs added to the Hetzner Cloud project. This way, I can just move the floating IPs around without having to manually configure the network interface on the nodes I assign those IPs to.

To use this, just add this little YAML as cloud init config in the node template, specifying 

* the Hetzner Cloud API token (required)
* a comma separated list of IPs that you want to whitelist in the firewall (required)
* the `--floating-ips` flag if you also want to configure floating IPs (optional)

NOTES: 

* the node driver allows selecting a private network if configured in the Hetzner Cloud project, however due to a limitation with Docker Machine (which node drivers use behind the scenes) the communication between the nodes for the Kubernetes services actually goes through the public interface, effectively rendering the private network useless in this case. For this reason, besides the firewall setup I recommend selecting [Weave](https://www.weave.works/blog/cni-for-docker-containers/) as the network provider when creating the cluster with Rancher, so to enable encryption of all the traffic between the nodes
* I recommend you whitelist your own IPs so you can connect to the cluster with kubectl etc
* Rancher's IP must be whitelisted otherwise it won't be able to complete the provisioning of Kubernetes
* The Hetzner Cloud API allows 3600 requests per hour, per project. If you don't enable floating IPs, each node will make one API request every minute, so this means that this solution will work just fine with up to 60 nodes max in the project, if nothing else is making API requests. In practice, other things will be making requests, like Rancher (when it creates/removes nodes) or the [CSI driver](https://github.com/hetznercloud/csi-driver) for block storage. If you enable floating IPs, then there will be two API requests per minute per node, so the max theoretical number of nodes for which this will work is 30.


```yaml
#cloud-config
locale: en_GB.UTF-8

runcmd:
  - "curl -s https://raw.githubusercontent.com/vitobotta/hetzner-cloud-init/master/setup.sh | bash -s -- --hcloud-token <TOKEN> --whitelisted-ips <WHITELIST> --floating-ips"
```