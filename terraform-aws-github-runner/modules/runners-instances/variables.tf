variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "tags" {
  description = "Map of tags that will be added to created resources. By default resources will be tagged with name and environment."
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "A name that identifies the environment, used as prefix and for tagging."
  type        = string
}

variable "s3_bucket_runner_binaries" {
  type = object({
    arn = string
  })
}
