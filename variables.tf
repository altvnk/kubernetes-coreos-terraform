variable tenant_id {}

variable master_flavor {}
variable node_flavor {}
variable image_name {}
variable floating_pool {}
variable external_net_id {}

variable public_key { default = "~/.ssh/id_rsa" }
variable keypair_name { default = "kubernetes" }

variable hostname_prefix { default = "kube" }
variable subnet_cidr { default = "192.168.0.0/24" }

variable kube_version { default = "1.0.6" }
variable kube_node_count { default = "2" }
variable kube_cluster_name { default = "cluster.local" }
variable kube_cluster_iprange { default = "10.254" }
variable kube_cluster_dns { default = ".0.53" }
variable kube_flannel_network { default = "4.0.0.0/16" }
