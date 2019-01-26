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
  security_group_ids = ["${openstack_compute_secgroup_v2.rhcsa_secgroup.id}"]

  fixed_ip {
    "subnet_id"  = "${openstack_networking_subnet_v2.rhcsa_subnet.id}"
    "ip_address" = "10.1.10.11"
  }
}

resource "openstack_networking_port_v2" "port_2" {
  name               = "port_2"
  network_id         = "${openstack_networking_network_v2.rhcsa_net.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.rhcsa_secgroup.id}"]

  fixed_ip {
    "subnet_id"  = "${openstack_networking_subnet_v2.rhcsa_subnet.id}"
    "ip_address" = "10.1.10.12"
  }
}

##----------------------------< Create a security group >----------------------------##
resource "openstack_compute_secgroup_v2" "rhcsa_secgroup" {
  name        = "rhcsa_secgroup"
  description = "Allow web traffic inbound"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-egress-18}"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-egress-18}"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "37.26.92.93/32"
    cidr        = "${module.ci-env.dc-egress-137}"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-egress-4}"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-egress-16}"
  }
}

##----------------------------< Create a rabbit security group >----------------------------##
resource "openstack_compute_secgroup_v2" "rabbit_secgroup" {
  name        = "rabbit_secgroup"
  description = "Allow web traffic inbound"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-egress-10}"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-egress-18}"
  }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-egress-12}"
  }

  rule {
    from_port   = 15672
    to_port     = 15672
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-egress-189}"
  }

  rule {
    from_port   = 15672
    to_port     = 15672
    ip_protocol = "tcp"
    cidr        = "${module.ci-env.dc-egress-108}"
  }

}
##----------------------------< instance  rhcsa_server create >----------------------------##
resource "openstack_compute_instance_v2" "rhcsa_server" {
  name      = "rhcsa_server"
  image_id  = "${module.ci-env.ubuntu-xenial}"
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

##----------------------------< rhcsa_client create >----------------------------##
resource "openstack_compute_instance_v2" "rhcsa_client" {
  name      = "rhcsa_client"
  image_id  = "${module.ci-env.ubuntu-xenial}"
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

