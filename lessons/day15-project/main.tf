
module "vpc" {
    source = "./resources/01_vpc"
    
    primary_vpc_cidr = var.primary_vpc_cidr
    secondary_vpc_cidr = var.secondary_vpc_cidr
    primary_region = var.primary_region
    secondary_region = var.secondary_region 
}

module "subnets" {
    source = "./resources/02_subnets"

    primary_vpc_id = module.vpc.primary_vpc_id
    secondary_vpc_id = module.vpc.secondary_vpc_id
    primary_region = var.primary_region
    secondary_region = var.secondary_region
    primary_subnet_cidr = var.primary_subnet_cidr
    secondary_subnet_cidr = var.secondary_subnet_cidr
}

module "internet_gateway" {
    source = "./resources/03_ig"

    primary_vpc_id = module.vpc.primary_vpc_id
    secondary_vpc_id = module.vpc.secondary_vpc_id
    primary_region = var.primary_region
    secondary_region = var.secondary_region 
}

module "route_table" {
    source = "./resources/04_route_table"

    primary_vpc_id = module.vpc.primary_vpc_id
    secondary_vpc_id = module.vpc.secondary_vpc_id
    primary_igw_id = module.internet_gateway.primary_igw_id
    secondary_igw_id = module.internet_gateway.secondary_igw_id
  
}

module "route_table_association" {

    source = "./resources/05_rta"

    primary_subnet_id = module.subnets.primary_subnet_id
    secondary_subnet_id = module.subnets.secondary_subnet_id
    primary_route_table_id = module.route_table.primary_rt_id
    secondary_route_table_id = module.route_table.secondary_rt_id
  
}

module "vpc_peering" {
    source = "./resources/06_vpc_peering"

    primary_vpc_id = module.vpc.primary_vpc_id
    secondary_vpc_id = module.vpc.secondary_vpc_id
    secondary_region = var.secondary_region

}

module "route" {
    source = "./resources/07_route"

    primary_rt_id = module.route_table.primary_rt_id
    primary_vpc_cidr = var.primary_vpc_cidr
    secondary_rt_id = module.route_table.secondary_rt_id
    secondary_vpc_cidr = var.secondary_vpc_cidr 
    vpc_peering_connection_id = module.vpc_peering.primary_to_secondary_id
 
}

module "security_group" {
    source = "./resources/08_sg"

    primary_sg_name = "${local.primary_name}-SG"
    secondary_sg_name = "${local.secondary_name}-SG"
    primary_vpc_id = module.vpc.primary_vpc_id
    secondary_vpc_id = module.vpc.secondary_vpc_id
    secondary_vpc_cidr = var.secondary_vpc_cidr
    primary_vpc_cidr = var.primary_vpc_cidr
  
}

module "EC2" {
    source = "./resources/09_ec2"
    
    primary_instance_name = alltrue()
    primary_ami = data.aws_ami.primary_ami.id
    secondary_ami = data.aws_ami.secondary_ami.id
    instance_type = var.instance_type
    primary_subnet_id = module.subnets.primary_subnet_id  
    secondary_subnet_id = module.subnets.secondary_subnet_id  
    primary_sg_id = module.security_group.primary_sg_id
    secondary_sg_id = module.security_group.secondary_sg_id
    primary_key_name = var.primary_key_name
    secondary_key_name = var.secondary_key_name
    primary_region = var.primary_region
    secondary_region = var.secondary_region
    primary_user_data = local.primary_user_data
    secondary_user_data = local.secondary_user_data
}