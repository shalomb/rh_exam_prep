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
  dns_nameservers = ["1.1.1.1"]
}

##----------------------------< router create >----------------------------##
resource "openstack_networking_router_v2" "R-RHCSA" {
  name                = "R-RHCSA"
  admin_state_up      = true
  external_network_id = "893a5b59-081a-4e3a-ac50-1e54e262c3fa"
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
    cidr        = "37.26.92.83/32"
  }
    rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "212.159.77.225/32"
  }
    rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "37.26.92.93/32"
  }
      rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "37.26.88.93/32"
  }
    rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "37.26.88.73/32"
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
    cidr        = "37.26.92.0/24"
  }
    rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "212.159.77.225/32"
  }
      rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "37.26.88.0/24"
  }
  rule {
    from_port   = 4369
    to_port     = 4369
    ip_protocol = "tcp"
    cidr        = "37.26.92.0/24"
  }
    rule {
    from_port   = 25672
    to_port     = 25672
    ip_protocol = "tcp"
    cidr        = "37.26.92.0/24"
  }
    rule {
    from_port   = 5671
    to_port     = 5672
    ip_protocol = "tcp"
    cidr        = "37.26.92.0/24"
  }
    rule {
    from_port   = 15672
    to_port     = 15672
    ip_protocol = "tcp"
    cidr        = "37.26.92.0/24"
  }
    rule {
    from_port   = 61613
    to_port     = 61614
    ip_protocol = "tcp"
    cidr        = "37.26.92.0/24"
  }
    rule {
    from_port   = 1883
    to_port     = 1883
    ip_protocol = "tcp"
    cidr        = "37.26.92.0/24"
  }
    rule {
    from_port   = 8883
    to_port     = 8883
    ip_protocol = "tcp"
    cidr        = "37.26.92.0/24"
  }
    rule {
    from_port   = 15672
    to_port     = 15672
    ip_protocol = "tcp"
    cidr        = "212.159.77.225/32"
  } 
}
##----------------------------< instance  rhcsa_server create >----------------------------##
resource "openstack_compute_instance_v2" "rhcsa_server" {
  name      = "rhcsa_server"
  image_id  = "073743b4-2eb1-479e-8a30-e480de174141"
  flavor_id = "c46be6d1-979d-4489-8ffe-e421a3c83fdd"

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
  image_id  = "073743b4-2eb1-479e-8a30-e480de174141"
  flavor_id = "c46be6d1-979d-4489-8ffe-e421a3c83fdd"

key_pair        = "bryce"
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

