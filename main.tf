terraform {
 required_version = ">= 1.9.5"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}

# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "os_image" {
  name = "${var.hostname}-os_image"
  pool = "default"
  source = "${var.source_dir}/${var.ubuntu_release}"
  format = "qcow2"
}

resource "libvirt_volume" "disk_ubuntu_resized" {
  name           = "${var.hostname}-disk"
  base_volume_id = libvirt_volume.os_image.id
  pool           = "default"
  size           = var.disk-size
}

resource "libvirt_cloudinit_disk" "commoninit" {
          name = "${var.hostname}-commoninit.iso"
          pool = "default"
          user_data = data.template_file.user_data.rendered
          network_config = data.template_file.network_config.rendered
}

data "template_file" "user_data" {
  template = file("cloud_init.cfg")
  vars = {
    hostname = var.hostname
    fqdn = "${var.hostname}.${var.domain}"
    domain = var.domain
    sitecode = var.sitecode
    repo = var.repo
    ssh_user = var.ssh_user
    ssh_hash_passwd = var.ssh_hash_passwd
  }
}

data "template_file" "network_config" {
  template = file("network_config_${var.ip_type}.cfg")
  vars = {
    domain = var.domain
    prefixIP = var.prefixIP
    octetIP = var.octetIP
    dnsIP = var.dnsIP
  }
}


# Create the machine
resource "libvirt_domain" "domain-ubuntu" {
  # domain name in libvirt, not hostname
  name = var.hostname
  memory = var.memoryMB
  vcpu = var.vcpu
  cpu = {
    mode = "host-passthrough"
  }

  disk {
       volume_id = libvirt_volume.disk_ubuntu_resized.id
  }
  network_interface {
       bridge = "br0"
       mac = var.mac
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}
