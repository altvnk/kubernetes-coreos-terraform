variable auth_url {}
variable tenant_id {}
variable tenant_name {}
variable public_key {}
variable keypair_name {}
variable cluster_name {}
variable master_flavor {}
variable node_flavor {}
variable image_name {}
variable floating_pool {}
variable external_net_id {}
variable kube_version {}
variable kube_node_count {}
variable kube_cluster_name {}
variable kube_cluster_iprange {}
variable kube_cluster_dns {}
variable kube_flannel_network {}

provider "openstack" {
  auth_url = "${ var.auth_url }"
  tenant_id = "${ var.tenant_id }"
  tenant_name = "${ var.tenant_name }"
}

module "kube-keypair" {
  source = "./terraform/keypair"
  public_key = "${ var.public_key }"
  keypair_name = "${ var.keypair_name }"
}

module "kube-secgroup" {
  source = "./terraform/secgroup"
  cluster_name = "${ var.cluster_name }"
}

module "kube-hosts" {
  source = "./terraform/hosts"
  master_flavor = "${ var.master_flavor }"
  node_flavor = "${ var.node_flavor }"
  image_name = "${ var.image_name }"
  keypair_name = "${ module.kube-keypair.keypair_name }"
  security_groups = "${ module.kube-secgroup.cluster_name }"
  node_count = "${ var.kube_node_count }"
  floating_pool = "${ var.floating_pool }"
  external_net_id = "${ var.external_net_id }"
}
