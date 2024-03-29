# Using the module from https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "webinar-vpc"
  cidr = "10.0.0.0/16"

  azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  database_subnets = ["10.0.51.0/24", "10.0.52.0/24", "10.0.53.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # We want to share the NAT gateway in each AZ with all the private subnets
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_vpn_gateway = false
  enable_s3_endpoint = true

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}
