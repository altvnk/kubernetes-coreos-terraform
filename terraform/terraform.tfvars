# copy this file and openstack.sample.tf or openstack-floating.sample.tf to
# the root directory before running terraform commands

# Specify Openstack values for authorization here
auth_url = ""
tenant_id = ""
tenant_name = ""

# Misc variables
public_key = "~/.ssh/id_rsa.pub"
keypair_name = ""
cluster_name = ""
master_flavor = ""
node_flavor = ""
image_name = "CoreOS"
floating_pool = ""
external_net_id = ""

# Kubernetes variables
master_count = "3"
node_count = "3"
kube_version = "v1.1.0"
kube_cluster_name = "cluster.local"
kube_cluster_iprange = "10.100.0.0/16"
kube_cluster_dns = "10.100.0.53"
flannel_network = "4.0.0.0/16"
