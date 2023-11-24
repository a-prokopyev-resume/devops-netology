variable "ip_address" {
    type          = string
    description   = "Validate IP address."
    default = "1.2.3.4"
    validation {
        condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.ip_address))
        error_message = "Incorrect IP address."
    }
}

variable "ip_addresses" {
    type          = list(string)
    description   = "Validate list of IP addresses."
    default = ["1.2.3.4", "2.3.4.5"]
    validation {
        condition = can([for ip in var.ip_addresses: regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip)])
        error_message = "Incorrect IP address."
    }
}


/*

variable "ip_address" {
  description = "ip address"
  type        = string
  default = "1.2.3.4"
  validation {
    condition     = can(cidrhost(var.ip_address))
    error_message = "ip_address is incorrect! Must be a valid IPv4 CIDR."
  }
}
*/

#    can(regex("^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}", var.ip_address))