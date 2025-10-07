variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "project_name" {
  description = "Project name for stage1"
  type        = string
  default     = "Default"
}

variable "project_description" {
  description = "Project description for stage1"
  type        = string
  default     = "Project for organization infrastructure"
}

variable "project_purpose" {
  description = "Project purpose for stage1"
  type        = string
  default     = "Hold Organization Resources such as remote terraform state"
}

variable "project_environment" {
  description = "Project environment for stage1"
  type        = string
  default     = "development"
}