variable ibm_bx_api_key {
  type    = "string"
  default = ""
}

variable ibm_sl_username {
  type    = "string"
  default = ""
}

variable ibm_sl_api_key {
  type    = "string"
  default = ""
}

variable datacenter {
  type = "map"

  default = {
    us-south1 = "dal10"
    us-south2 = "dal12"
    us-south3 = "dal13"
    us-east1  = "wdc04"
    us-east2  = "wdc06"
    us-east3  = "wdc07"
  }
}

variable os_reference_code {
  type = "map"

  default = {
    u16  = "UBUNTU_16_64"
    deb9 = "DEBIAN_9_64"
  }
}

variable flavor_key_name {
  type = "map"

  default = {
    pxe = "B1_8X16X100"
  }
}

variable domain {
  type    = "string"
  default = "example.com"
}

variable hostname {
  type    = "string"
  default = ""
}

variable user_metadata {
  type    = "string"
  default = ""
}
