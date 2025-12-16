variable "aws_region" {
  description = "AWS region to use"
  type        = string
  default     = "sa-east-1"
}

variable "aws_access_key" {
  description = "AWS access key (for LocalStack)"
  type        = string
  default     = "test"
}

variable "aws_secret_key" {
  description = "AWS secret key (for LocalStack)"
  type        = string
  default     = "test"
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL for S3 (e.g. http://localhost:4566)"
  type        = string
  default     = "http://localhost:4566"
}

variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}
