# variables that can be overriden

variable "hostname" {} 
variable "domain" {} 
variable "ip_type" {} # dhcp is other valid type 
variable "memoryMB" {} 
variable "vcpu" {} 

## Disk sizes
variable "disk-size" {}

variable "prefixIP" {} 
variable "octetIP" {}
variable "dnsIP" {}
variable "mac" {}

variable "sitecode" {}
variable "repo" {}
variable "ubuntu_release" {}
variable "source_dir" {}

variable "ssh_user" {}
variable "ssh_passwd" {}
variable "ssh_hash_passwd" {}
