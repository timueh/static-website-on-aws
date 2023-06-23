variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy to"
}

variable "subscription_email" {
  type        = string
  description = "email address that will receive subscription (note: subscription must be confirmed!)"
  sensitive   = true
}

variable "prefix" {
  type        = string
  default     = "tf"
  description = "prefix for deployed resources"
}