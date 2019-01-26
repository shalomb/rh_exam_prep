# Variables for openstack-ukcloud-dev

# Import the openstack datacenter inventory

output "keypair" {
  value = "bryce"
}

output "dc-dns-nameservers" {
  value = [ "1.1.1.1", "8.8.8.8" ]  # Defined as a list here but consumed as a scalar by caller
}

output "dc-ext-net-id" {
  value = "893a5b59-081a-4e3a-ac50-1e54e262c3fa"
}

output "dc-ingress-1" {
  value = "212.159.77.225/32"
}

output "dc-ingress-2" {
  value = "37.26.92.0/24"
}
output "dc-ingress-3" {
  value = "37.26.88.0/24"
}
# ...

output "centos-latest" {
  value = "073743b4-2eb1-479e-8a30-e480de174141"
  # or better get this out of OS directly
  # value = "${data.openstack_images_image_v2.xenial.id}"
}

output "x1-small" {
  value = "c46be6d1-979d-4489-8ffe-e421a3c83fdd"
  # or better get this out of OS directly
  # value = "${data.openstack_compute_flavor_v2.x1-small.id}"
}
