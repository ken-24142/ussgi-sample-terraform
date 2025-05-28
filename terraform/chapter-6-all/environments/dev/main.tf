# ====================================================
# 管理（作成）するリソースたち
# ====================================================
### 共通で使う値はここで定義する
locals {  
  prefix                 = "samp01"
}

### VPC、サブネット
module "network" {
  source                 = "../../modules/network"
  prefix                 = local.prefix
  vpc_cidr               = "172.21.0.0/16"
  availability_zones     = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  public_subnets_cidr    = ["172.21.0.0/24", "172.21.1.0/24", "172.21.2.0/24"]
  private_subnets_cidr   = ["172.21.10.0/24", "172.21.11.0/24", "172.21.12.0/24"]
  intra_subnets_cidr     = ["172.21.20.0/24", "172.21.21.0/24", "172.21.22.0/24"]
}

### ELB
module "elb" {
  source                   = "../../modules/elb"
  prefix                   = local.prefix
  samp_vpc_id              = module.network.samp_vpc_id
  samp_vpc_cidr            = module.network.samp_vpc_cidr
  samp_subnet_pub_id_0     = module.network.samp_subnet_pub_id_0
  samp_subnet_pub_id_1     = module.network.samp_subnet_pub_id_1
  samp_subnet_pub_id_2     = module.network.samp_subnet_pub_id_2
  samp_s3_endpoint_id      = module.network.samp_s3_endpoint_id
  alb_source_ip_range      = "0.0.0.0/0"  # アクセス元IPアドレスへ変更する
  samp_alb_certificate_arn = module.domain.samp_alb_certificate_arn  
}

### ECS
module "ecs" {
  source                 = "../../modules/ecs"
  prefix                 = local.prefix
  samp_vpc_id            = module.network.samp_vpc_id
  samp_vpc_cidr          = module.network.samp_vpc_cidr
  samp_subnet_pri_id_0   = module.network.samp_subnet_pri_id_0
  samp_subnet_pri_id_1   = module.network.samp_subnet_pri_id_1
  samp_subnet_pri_id_2   = module.network.samp_subnet_pri_id_2
  target_group_1_arn     = module.elb.target_group_1_arn
  samp_ecs_task_cpu      = 256
  samp_ecs_task_memory   = 512
  samp_log_retention_in_days = 7
}

### Route53, ACM
module "domain" {
  source                 = "../../modules/domain"
  samp_domain_name       = "<先ほど追加したドメイン名>"
  samp_lb_dns_name       = module.elb.samp_lb_dns_name
  samp_lb_zone_id        = module.elb.samp_lb_zone_id
}