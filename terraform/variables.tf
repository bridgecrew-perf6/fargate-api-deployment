variable "cluster" {
  description = "The cluster name or ARN"
  default     = "cluster"
  type        = string
}

variable "service_desired_count" {
  description = "The tasks desired count"
  type        = string
  default     = 1
}

variable "aws_region" {
  description = "AWS region to use"
  default     = "us-east-1"
  type        = string
}

variable "service_port" {
  description = "Application/Service port"
  default = {
    "service-service" = "8000"
    "example-service" = "32500"
  }
  type = map(string)
}

variable "app_port" {
  description = "Application/Service port"
  default     = 8000
  type        = number
}

variable "listener_priority_service" {
  description = "Load balancer listener priority rule"
  type        = string
}

variable "task_cpu" {
  description = "Application/Service CPU reservation"
  default     = "256"
  type        = string
}

variable "task_memory" {
  description = "Application/Service Memory reservation"
  default     = "512"
  type        = string
}

variable "instance_tenancy" {
  default = "default"
  type    = string
}

variable "vpc_cidr_block" {
  description = "VPC CIRD block eg. 192.168.0.0/16"
  default     = "10.0.0.0/16"
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "Subnet match CIDR block"
  default     = "10.0.1.0/24"
  type        = string
}

variable "private_subnet_cidr_block" {
  description = "Subnet match CIDR block"
  default     = "10.0.2.0/24"
  type        = string
}

variable "dest_cidr_block" {
  default = "0.0.0.0/0"
  type    = string
}

variable "ingress_cidr_block" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "map_public_ip" {
  default = true
  type    = bool
}