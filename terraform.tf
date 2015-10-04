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
  cluster_name = "${ var.kube_cluster_name }"
}

module "hosts" {
  source = "./terraform/hosts"
  short_name = "${var.hostname_prefix}"
  subnet_cidr = "${var.subnet_cidr}"
  master_flavor = "${ var.master_flavor }"
  node_flavor = "${ var.node_flavor }"
  image_name = "${ var.image_name }"
  keypair_name = "${ module.keypair.keypair_name }"
  security_groups = "${ module.secgroup.cluster_name }"
  master_count = "${ var.master_count }"
  node_count = "${ var.node_count }"
  floating_pool = "${ var.floating_pool }"
  external_net_id = "${ var.external_net_id }"
  kube_version = "${var.kube_version}"
}
