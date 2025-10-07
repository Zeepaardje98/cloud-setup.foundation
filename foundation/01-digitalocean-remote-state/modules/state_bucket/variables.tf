variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "project_id" {
  description = "ID of the existing project from stage1"
  type        = string
}
