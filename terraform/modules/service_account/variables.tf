variable "account_id" {
  type        = string
  description = "The account id that is used to generate the service account email address and a stable unique id"
}

variable "display_name" {
  type        = string
  description = "The display name for the service account"
  default     = null
}

variable "description" {
  type        = string
  description = "A text description of the service account"
  default     = null
}

variable "roles" {
  type        = list(string)
  description = "A list of roles"
  default     = []
}
