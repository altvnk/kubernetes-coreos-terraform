# copy this file and openstack.sample.tf or openstack-floating.sample.tf to
# the root directory before running terraform commands

# specify Openstack values for authorization here
auth_url = ""
tenant_id = ""
tenant_name = ""
# Kubernetes variables
kube_version = "v1.0.0"
kube_node_count = "2"
kube_cluster_name = "cluster.local"
kube_cluster_iprange = "10.100.0.0/16"
kube_cluster_dns = "10.100.0.53"
kube_flannel_network = "4.0.0.0/16"
