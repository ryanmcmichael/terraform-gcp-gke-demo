variable "name" {
  type        = string
  description = "Name of the subproject"
}

variable "description" {
  type        = string
  description = "Description of the Cloud Function"
}

variable "bucket_name" {
  type        = string
  description = "GCS bucket name"
}

variable "entry_point" {
  type        = string
  description = "Name of the function that will be executed"
}

variable "service_account_email" {
  type        = string
  description = "Service account email"
  default     = null
}

variable "allow_unauthenticated_invocations" {
  type        = bool
  description = "Allow unauthenticated invocations of the Cloud Function"
  default     = true
}

variable "available_memory_mb" {
  type        = number
  description = "Available memory in MB"
  default     = 256
}
