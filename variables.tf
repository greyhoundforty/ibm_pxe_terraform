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
  }
}

variable node_count {
  type    = "string"
  default = "1"
}

variable os_reference_code {
  type = "string"

  default = {
    u16 = "UBUNTU_16_64"
  }
}

variable flavor_key_name {
  type = "string"

  default = {
    pxe = "B1_8X16X100"
  }
}

variable domain {
  type    = "string"
  default = ""
}

variable hostname {
  type    = "string"
  default = ""
}

variable user_metadata {
  type    = "string"
  default = ""
}

variable localdisk {
  type    = "string"
  default = ""
}
