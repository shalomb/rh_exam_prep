data "template_file" "cloudconfig" {
  template = "${file("userdata.yml.tpl")}"
}

data "local_file" "rabbit-sh" {
  filename = "rabbit.sh"
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.cloudconfig.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.local_file.meta-data-fact.content}"
  }

}

