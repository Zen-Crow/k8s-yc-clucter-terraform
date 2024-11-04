variable "cloud_id" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

variable "token" {
  type      = string
  sensitive = false
}

variable "name_prefix" {
  description = "Name prefix for project."
  type        = string
  default     = "cloud1"
}

variable "vpc_network_name" {
  description = "Name of the VPC network."
  type        = string
  default     = null
}

variable "zones" {
  description = "Yandex Cloud Zones."
  type        = set(string)
  default     = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

variable "subnets" {
  description = "(Optional) - A map of AZ to subnets CIDR block ranges."
  type        = map(list(string))
  default = {
    "ru-central1-a" = ["192.168.10.0/24"],
    "ru-central1-b" = ["192.168.11.0/24"],
    "ru-central1-d" = ["192.168.12.0/24"]
  }
}
