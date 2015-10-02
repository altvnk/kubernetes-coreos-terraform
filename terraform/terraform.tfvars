# copy this file and openstack.sample.tf or openstack-floating.sample.tf to
# the root directory before running terraform commands

# Specify Openstack values for authorization here
auth_url = ""
tenant_id = ""
tenant_name = ""

# Misc variables
public_key = ""
keypair_name = ""
cluster_name = ""
master_flavor = ""
node_flavor = ""
image_name = ""
floating_pool = ""
external_net_id = ""

# Kubernetes variables
kube_version = "v1.0.0"
kube_node_count = "2"
kube_cluster_name = "cluster.local"
kube_cluster_iprange = "10.100.0.0/16"
kube_cluster_dns = "10.100.0.53"
kube_flannel_network = "4.0.0.0/16"
