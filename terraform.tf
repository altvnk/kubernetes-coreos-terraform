provider "openstack" {
  tenant_id = "${ var.tenant_id }"
}

module "keypair" {
  source = "./terraform/keypair"
  public_key = "${ var.public_key }"
  keypair_name = "${ var.keypair_name }"
}

module "secgroup" {
  source = "./terraform/secgroup"
  cluster_name = "${ var.cluster_name }"
}

module "hosts" {
  source = "./terraform/hosts"
  short_name = "${var.hostname_prefix}"
  subnet_cidr = "${var.subnet_cidr}"
  master_flavor = "${ var.master_flavor }"
  node_flavor = "${ var.node_flavor }"
  image_name = "${ var.image_name }"
  keypair_name = "${ module.kube-keypair.keypair_name }"
  security_groups = "${ module.kube-secgroup.cluster_name }"
  node_count = "${ var.kube_node_count }"
  floating_pool = "${ var.floating_pool }"
  external_net_id = "${ var.external_net_id }"
  kube_version = "${var.kube_version}"
}
