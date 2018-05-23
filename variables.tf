variable "name" {
  description = "The ECS cluster name this will launching instances for."
}

variable "environment" {
  description = "Environment tag."
}

variable "image_id" {
  description = "Amazon ECS-Optimized AMI."
}

variable "instance_type" {
  description = "The instance type to use."
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "The id of the VPC to launch resources in."
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch resources in."
  type        = "list"
}

variable "desired_capacity" {
  description = "Desired instance count."
  default     = 2
}

variable "max_size" {
  description = "Maxmimum instance count."
  default     = 2
}

variable "min_size" {
  description = "Minimum instance count."
  default     = 2
}
