variable master_flavor {}
variable node_flavor {}
variable keypair_name {}
variable image_name {}
variable master_count {}
variable node_count {}
variable security_groups {}
variable floating_pool {}
variable external_net_id {}
variable subnet_cidr {}
variable ip_version { default = "4" }
variable short_name {}
variable kube_version {}

resource "template_file" "cloud-init-master" {
  filename = "cloud-configs/master.yaml"
}

resource "template_file" "cloud-init-node" {
  filename = "cloud-configs/node.yaml"
  vars {
    master_address = "${ openstack_compute_instance_v2.master.0.network.0.fixed_ip_v4 }"
    kube_version = "${ var.kube_version }"
  }
}

resource "openstack_compute_instance_v2" "master" {
  floating_ip = "${ element(openstack_compute_floatingip_v2.master-floatip.*.address, count.index) }"
  name                  = "${ var.short_name }-master-${ format("%02d", count.index+1) }"
  key_pair              = "${ var.keypair_name }"
  image_name            = "${ var.image_name }"
  flavor_name           = "${ var.master_flavor }"
  security_groups       = [ "${ var.security_groups }", "default" ]
  network               = { uuid = "${ openstack_networking_network_v2.network.id }" }
  count                 = "${ var.master_count }"
  metadata              = {
                            role = "master"
                          }
  #user_data = "${ template_file.cloud-init.rendered }"
}

resource "openstack_compute_instance_v2" "node" {
  floating_ip = "${ element(openstack_compute_floatingip_v2.node-floatip.*.address, count.index) }"
  name                  = "${ var.short_name}-node-${format("%02d", count.index+1) }"
  key_pair              = "${ var.keypair_name }"
  image_name            = "${ var.image_name }"
  flavor_name           = "${ var.node_flavor }"
  security_groups       = [ "${ var.security_groups }", "default" ]
  network               = { uuid = "${ openstack_networking_network_v2.network.id }" }
  count                 = "${ var.node_count }"
  metadata              = {
                            role = "node"
                          }
  #user_data             = "${ template_file.cloud-init-node.rendered }"
  depends_on            = "openstack_compute_instance_v2.master"
}

resource "openstack_compute_floatingip_v2" "master-floatip" {
  pool 	     = "${ var.floating_pool }"
  count      = "${ var.master_count }"
  depends_on = [ "openstack_networking_router_v2.router",
                 "openstack_networking_network_v2.network",
                 "openstack_networking_router_interface_v2.router-interface" ]
}

resource "openstack_compute_floatingip_v2" "node-floatip" {
  pool       = "${ var.floating_pool }"
  count      = "${ var.node_count }"
  depends_on = [ "openstack_networking_router_v2.router",
                 "openstack_networking_network_v2.network",
                 "openstack_networking_router_interface_v2.router-interface" ]
}

resource "openstack_networking_network_v2" "network" {
  name = "${ var.short_name }-network"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name          = "${ var.short_name }-subnet"
  network_id    = "${ openstack_networking_network_v2.network.id }"
  cidr          = "${ var.subnet_cidr }"
  ip_version    = "${ var.ip_version }"
}

resource "openstack_networking_router_v2" "router" {
  name             = "${ var.short_name }-router"
  external_gateway = "${ var.external_net_id }"
}

resource "openstack_networking_router_interface_v2" "router-interface" {
  router_id = "${ openstack_networking_router_v2.router.id }"
  subnet_id = "${ openstack_networking_subnet_v2.subnet.id }"
}
