module "turma07" {
  source = "terraform-aws-modules/vpc/aws"

  name = "turma07-vpc"
  cidr = "10.0.0.0/16"

  azs = ["us-east-1a","us-east-1c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  create_egress_only_igw = true

  tags = {
    env = "prod"
    projeto = "Turma07"
}

}
output "vpc_id" {
  value = module.turma07.vpc_id
}

output "subnets_id" {
  value = module.turma07.public_subnets