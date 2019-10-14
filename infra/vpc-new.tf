# Using the module from https://github.com/terraform-aws-modules/terraform-aws-vpc
module "vpc_new" {
  providers = {
    aws = "aws.new"
  }

  source = "terraform-aws-modules/vpc/aws"

  name = "webinar-vpc"
  cidr = "10.10.0.0/16"

  azs = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]

  private_subnets  = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  database_subnets = ["10.10.51.0/24", "10.10.52.0/24", "10.10.53.0/24"]
  public_subnets   = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

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
