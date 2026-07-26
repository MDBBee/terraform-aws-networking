

variable "vpc_config" {
  description = "Configuration for the VPC. Requires a valid CIDR block and a name."

  type = object({
    cidr_block = string
    name       = string
  })

  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "The cidr_block config option must contain a valid CIDR block."
  }
}

variable "subnet_config" {
  description = "Map of subnet definitions. Each key becomes the subnet Name tag and output key. Set public = true to route through the Internet Gateway."

  type = map(object({
    cidr_block = string
    public     = optional(bool, false)
    az         = string
  }))


  validation {
    condition = alltrue([
      for config in values(var.subnet_config) : can(cidrnetmask(config.cidr_block))
    ])
    error_message = "The cidr_block config option must contain a valid CIDR block."
  }
}

