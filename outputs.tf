# 1. VPC ID
# 2. Public subnets - subnet_key => { subnet_id, availability_zone }
# 3. Private subnets - subnet_key => { subnet_id, availability_zone }

# EXAMPLE:local.public_subnets = {
#   subnet_1 = {
#     az = "eu-north-1b"
#     cidr_block = "10.0.0.0/24"
#     public = true
#   }
# }
locals {
  output_public_subnets = {
    for key in keys(local.public_subnets) : key => {
      subnet_id         = aws_subnet.this[key].id
      availability_zone = aws_subnet.this[key].availability_zone
    }
  }

  output_private_subnets = {
    for key in keys(local.private_subnets) : key => {
      subnet_id         = aws_subnet.this[key].id
      availability_zone = aws_subnet.this[key].availability_zone
    }
  }
}

output "vpc_id" {
  description = "The ID of the created VPC."

  value = aws_vpc.this.id
}

output "public_subnets" {
  description = "Map of public subnets keyed by subnet_config key. Each value contains the subnet ID and availability zone. Empty if no public subnets are defined."

  value = local.output_public_subnets
}

output "private_subnets" {
  description = "Map of private subnets keyed by subnet_config key. Each value contains the subnet ID and availability zone. Empty if all subnets are public."

  value = local.output_private_subnets
}