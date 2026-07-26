# terraform-aws-networking

Terraform module that provisions a VPC with public and private subnets, an Internet Gateway, and a public route table. The IGW and route table are created conditionally — only when at least one public subnet exists.

## Resources

| Resource | Condition |
|---|---|
| `aws_vpc` | Always |
| `aws_subnet` | Always (one per `subnet_config` entry) |
| `aws_internet_gateway` | At least one public subnet |
| `aws_route_table` | At least one public subnet |
| `aws_route_table_association` | At least one public subnet |

## Usage

### Mixed public and private subnets

```hcl
module "vpc" {
  source = "./modules/networking"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "my-vpc"
  }

  subnet_config = {
    private_app = {
      cidr_block = "10.0.0.0/24"
      az         = "eu-north-1a"
    }
    private_db = {
      cidr_block = "10.0.1.0/24"
      az         = "eu-north-1b"
    }
    public_web = {
      cidr_block = "10.0.2.0/24"
      public     = true
      az         = "eu-north-1a"
    }
  }
}
```

### Private-only VPC

Omitting `public = true` on all subnets skips the IGW, route table, and route table associations entirely.

```hcl
module "vpc" {
  source = "./modules/networking"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "isolated-vpc"
  }

  subnet_config = {
    app = {
      cidr_block = "10.0.0.0/24"
      az         = "eu-north-1a"
    }
    db = {
      cidr_block = "10.0.1.0/24"
      az         = "eu-north-1b"
    }
  }
}
```

## Inputs

### `vpc_config`

| Key | Type | Required | Description |
|---|---|---|---|
| `cidr_block` | `string` | Yes | Valid CIDR block for the VPC. |
| `name` | `string` | Yes | Name tag for the VPC. |

### `subnet_config`

A map of subnet definitions. Each key becomes the subnet's `Name` tag and the key used in outputs.

| Key | Type | Required | Default | Description |
|---|---|---|---|---|
| `cidr_block` | `string` | Yes | — | Valid CIDR block for the subnet. |
| `az` | `string` | Yes | — | Availability zone. Validated against the current region. |
| `public` | `bool` | No | `false` | Set to `true` to create a public subnet with IGW routing. |

## Outputs

### `vpc_id`

```
type: string
```

The ID of the created VPC.

```
"vpc-0a1b2c3d4e5f6a7b8"
```

### `public_subnets`

```
type: map(object({
  subnet_id         = string
  availability_zone = string
}))
```

Map of public subnets keyed by the same keys from `subnet_config`. Only entries where `public = true` appear here. Empty map if no public subnets are defined.

```hcl
{
  public_web = {
    subnet_id         = "subnet-0a1b2c3d4e5f6a7b8"
    availability_zone = "eu-north-1a"
  }
}
```

### `private_subnets`

```
type: map(object({
  subnet_id         = string
  availability_zone = string
}))
```

Map of private subnets keyed by the same keys from `subnet_config`. Only entries where `public` is omitted or `false` appear here. Empty map if all subnets are public.

```hcl
{
  private_app = {
    subnet_id         = "subnet-0f1e2d3c4b5a69788"
    availability_zone = "eu-north-1a"
  }
  private_db = {
    subnet_id         = "subnet-0a9b8c7d6e5f43210"
    availability_zone = "eu-north-1b"
  }
}
```

### Referencing outputs

```hcl
module.vpc.vpc_id
module.vpc.public_subnets["public_web"].subnet_id
module.vpc.private_subnets["private_db"].availability_zone
```

## Validations

- `vpc_config.cidr_block` must be a valid CIDR block.
- Every `subnet_config[*].cidr_block` must be a valid CIDR block.
- Every `subnet_config[*].az` must exist in the current AWS region.
