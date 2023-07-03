variable "bucket_name" {
  type        = string
  description = "Name for S3 bucket"
}

variable "elb_service_account_arn" {
  type        = string
  description = "ARN of ELB for logs"
}

variable "common_tags" {
  type        = map(string)
  description = "Map of tags to be applied to all resources"
  default     = {}
}