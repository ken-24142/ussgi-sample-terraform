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
