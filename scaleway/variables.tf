variable "scw_org" {}

variable "scw_token" {}

variable "region" {
  default = "ams1"
}

variable "master_type" {
  default     = "START1-S"
  description = "ScaleWay server type ex. C2S"
}

variable "master_count" {
  default     = 3
  description = "Number of masters to spawn"
}

variable "worker_type" {
  default     = "START1-S"
  description = "ScaleWay server type ex. C2S"
}

variable "worker_count" {
  default     = 3
  description = "Number of workers to spawn"
}

variable "prefix" {
  description = "Prefix that will be added to server names and resources"
}
