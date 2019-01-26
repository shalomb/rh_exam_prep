# Configure the OpenStack Provider
provider "openstack" {}
##----------------------------< rhcsa_net create >----------------------------##
resource "openstack_networking_network_v2" "rhcsa_net" {
  name           = "rhcsa_net"
  admin_state_up = "true"
}
##----------------------------< Create a subnet and attach to rhcsa_net >----------------------------##
resource "openstack_networking_subnet_v2" "rhcsa_subnet" {
  name       = "rhcsa_subnet"
  network_id = "${openstack_networking_network_v2.rhcsa_net.id}"
  cidr       = "10.1.10.0/24"
  ip_version = 4
  dns_nameservers = "${module.ci-env.dc-dns-nameservers}"
}
##----------------------------< router create >----------------------------##
resource "openstack_networking_router_v2" "R-RHCSA" {
  name                = "R-RHCSA"
  admin_state_up      = true
  external_network_id = "${module.ci-env.dc-ext-net-id}"
}
##----------------------------< attach R-RHCSA to rhcsa_net >----------------------------##
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = "${openstack_networking_router_v2.R-RHCSA.id}"
  subnet_id = "${openstack_networking_subnet_v2.rhcsa_subnet.id}"
}
##----------------------------< create ports and attach to rhcsa_net >----------------------------##
resource "openstack_networking_port_v2" "port_1" {
  name               = "port_1"
  network_id         = "${openstack_networking_network_v2.rhcsa_net.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.rabbit_secgroup.id}"]
  fixed_ip {
    "subnet_id"  = "${openstack_networking_subnet_v2.rhcsa_subnet.id}"
    "ip_address" = "10.1.10.11"
  }
}
resource "openstack_networking_port_v2" "port_2" {
  name               = "port_2"
  network_id         = "${openstack_networking_network_v2.rhcsa_net.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.rabbit_secgroup.id}"]
  fixed_ip {
    "subnet_id"  = "${openstack_networking_subnet_v2.rhcsa_subnet.id}"
    "ip_address" = "10.1.10.12"
  }
}
##----------------------------< Create a rabbit security group >----------------------------##
resource "openstack_compute_secgroup_v2" "rabbit_secgroup" {
  name        = "rabbit_secgroup"
  description = "Allow access to rabbitmq"
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-ingress-1}"
  }
  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-ingress-2}"
  }
  rule {
    from_port   = 15672
    to_port     = 15672
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-ingress-1}"
  }
  rule {
    from_port   = 15672
    to_port     = 15672
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-ingress-2}"
  }
}
##----------------------------< instance  rhcsa_server create >----------------------------##
resource "openstack_compute_instance_v2" "rhcsa_server" {
  name      = "rhcsa_server"
  image_id  = "${module.ci-env.centos-latest}"
  flavor_id = "${module.ci-env.x1-small}"
  key_pair        = "bryce"
  security_groups = ["${openstack_compute_secgroup_v2.rabbit_secgroup.name}"]
  metadata {
    this = "rhcsa_server"
  }
  network {
    port = "${openstack_networking_port_v2.port_1.id}"
  }
  user_data = "${file("rabbit.sh")}"
}
##----------------------------< rabbit create >----------------------------##
resource "openstack_compute_instance_v2" "rabbit_server" {
  name      = "rabbit_server"
  image_id  = "${module.ci-env.centos-rabbit}"
  flavor_id = "${module.ci-env.x1-small}"
  key_pair        = "${module.ci-env.keypair}"
  security_groups = ["${openstack_compute_secgroup_v2.rabbit_secgroup.name}"]
  metadata {
    this = "node1"
  }
  network {
    port = "${openstack_networking_port_v2.port_2.id}"
  }
  user_data = "${file("node.sh")}"
}
##----------------------------< floating ip create -1 >----------------------------##
resource "openstack_networking_floatingip_v2" "floatip_1" {
  pool = "internet"
}
resource "openstack_compute_floatingip_associate_v2" "floatip_1" {
  floating_ip = "${openstack_networking_floatingip_v2.floatip_1.address}"
  instance_id = "${openstack_compute_instance_v2.rhcsa_server.id}"
}
##----------------------------< floating ip create -2 >----------------------------##
resource "openstack_networking_floatingip_v2" "floatip_2" {
  pool = "internet"
}
resource "openstack_compute_floatingip_associate_v2" "floatip_2" {
  floating_ip = "${openstack_networking_floatingip_v2.floatip_2.address}"
  instance_id = "${openstack_compute_instance_v2.rabbit_server.id}"
}