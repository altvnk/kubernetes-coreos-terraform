variable master_flavor { }
variable node_flavor { }
variable keypair_name { }
variable image_name { }
variable node_count { }
variable master_count { }
variable security_groups { }
variable floating_pool { }
variable external_net_id { }
variable subnet_cidr { default = "10.10.1.0/24" }
variable ip_version { default = "4" }
variable short_name { default = "kube" }
variable long_name { default = "kubernetes" }
variable docker_node_volume { default = 20 }
variable etcd_discovery_file { default = "etcd_discovery_url.txt" }
variable flannel_network { default = "4.0.0.0/16" }
variable kube_cluster_name { }
variable kube_cluster_iprange { }
variable kube_cluster_dns { }

resource "template_file" "etcd_discovery_url" {
  filename      = "/dev/null"
  provisioner "local-exec" {
        command = "curl https://discovery.etcd.io/new?size=${var.master_count} > ${var.etcd_discovery_file}"
    }
}

resource "template_file" "cloud-init-master" {
  count         = "${ var.master_count }"
  filename      = "cloud-configs/master.yaml"
  vars {
    hostname           = "${ var.short_name }-master-${ format("%02d", count.index+1) }"
    etcd_discovery_url = "${ file(var.etcd_discovery_file) }"
    flannel_network    = "${ var.flannel_network }"
    kube_cluster_name  = "${ var.kube_cluster_name }"
    kube_cluster_iprange  = "${ var.kube_cluster_iprange }"
    kube_cluster_dns  = "${ var.kube_cluster_dns }"
  }
  depends_on    = "template_file.etcd_discovery_url"
}

resource "template_file" "cloud-init-node" {
  filename = "cloud-configs/node.yaml"
  vars {
    hostname          = "${ var.short_name }-node-${ format("%02d", count.index+1) }"
    master            = "${ openstack_compute_instance_v2.master.0.network.0.fixed_ip_v4 }"
    etcd_list         = "${ join(",", formatlist("%s=http://%s:2380", openstack_compute_instance_v2.master.*.name, openstack_compute_instance_v2.master.*.network.0.fixed_ip_v4)) }"
    flannel_network   = "${ var.flannel_network }"
  }
}

resource "openstack_blockstorage_volume_v1" "node-volume" {
  name          = "${ var.short_name }-node-${format("%02d", count.index+1) }"
  description   = "${ var.short_name }-node-${format("%02d", count.index+1) }"
  size          = "${ var.docker_node_volume }"
  count         = "${ var.node_count }"
}

resource "openstack_compute_instance_v2" "master" {
  floating_ip = "${ element(openstack_compute_floatingip_v2.master-floatip.*.address, count.index) }"
  name = "${ var.short_name }-master-${ format("%02d", count.index+1) }"
  key_pair = "${ var.keypair_name }"
  image_name = "${ var.image_name }"
  flavor_name = "${ var.master_flavor }"
  security_groups = [ "${ var.security_groups }", "default" ]
  network = { uuid = "${ openstack_networking_network_v2.network.id }" }
  count = "${ var.master_count }"
  metadata = {
    role = "master"
  }
  user_data = "${element(template_file.cloud-init-master.*.rendered, count.index)}"
}

resource "openstack_compute_instance_v2" "node" {
  floating_ip = "${ element(openstack_compute_floatingip_v2.node-floatip.*.address, count.index) }"
  name                  = "${ var.short_name}-node-${format("%02d", count.index+1) }"
  key_pair              = "${ var.keypair_name }"
  image_name            = "${ var.image_name }"
  flavor_name           = "${ var.node_flavor }"
  security_groups       = [ "${ var.security_groups }", "default" ]
  network               = { uuid = "${ openstack_networking_network_v2.network.id }" }
  volume                = {
                            volume_id   = "${ element(openstack_blockstorage_volume_v1.node-volume.*.id, count.index) }"
                            device      = "/dev/vdb"
                          }
  metadata              = {
                            role = "node"
                          }
  count                 = "${ var.node_count }"
  user_data             = "${ template_file.cloud-init-node.rendered }"
  depends_on            = "openstack_compute_instance_v2.master"
}

resource "openstack_compute_floatingip_v2" "master-floatip" {
  pool          = "${ var.floating_pool }"
  count         = "${ var.master_count }"
  depends_on    = [ "openstack_networking_router_v2.router",
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
