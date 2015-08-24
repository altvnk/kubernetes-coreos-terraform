variable auth_url {}
variable tenant_id {}
variable tenant_name {}

provider "openstack" {
  auth_url = "${ var.auth_url }"
  tenant_id = "${ var.tenant_id }"
  tenant_name = "${ var.tenant_name }"
}

module "kube-keypair" {
  source = "./terraform/keypair"
  public_key = ""
  keypair_name = ""
}

module "kube-secgroup" {
  source = "./terraform/secgroup"
  cluster_name = "k8s-cluster"
}

module "kube-hosts" {
  source = "./terraform/hosts"
  master_flavor = ""
  node_flavor = ""
  image_name = ""
  keypair_name = "${ module.kube-keypair.keypair_name }"
  security_groups = "${ module.kube-secgroup.cluster_name }"
  node_count = 2
  floating_pool = ""
  external_net_id = ""
}
