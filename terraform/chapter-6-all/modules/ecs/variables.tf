# ====================================================
# モジュールで使う変数
# ====================================================
variable "target_group_1_arn" {}
variable "prefix" {}
variable "samp_vpc_id" {}
variable "samp_vpc_cidr" {}
variable "samp_subnet_pri_id_0" {}
variable "samp_subnet_pri_id_1" {}
variable "samp_subnet_pri_id_2" {}
variable "samp_ecs_task_cpu" { type = number }
variable "samp_ecs_task_memory" { type = number }
variable "samp_log_retention_in_days" { type = number }