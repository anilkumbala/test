variable "fifo_queue" {
  default     = "false"
  description = "If set to False this creates a Standard SQS queue"
}

variable "default_tags" { 
    type = map 
    default = { 
        Domain:             "marketing"
        Domain_Short:       "mktg"
		Environment:        "dev"
		Service:            "baskewriter"
        Service_Short:      "np"
        Service_No:         "001"
		Project:            "loyalty"
        Region:             "eu-west-1"
        Region_code:        "euw1"
         } 
}
variable "region_code" {
    default     = "euw1"
    description = "short AWS region code"
}
    
variable "environment" {
    default     = "dev"
    description = "dev, sit, uat, pre"
}
   
variable "owner_short" {
    default     = "mktg"
    description = "business owner domain, e.g. marketing, digital, people"
} 

variable "owner_name" {
    default     = "marketing"
    description = "business owner domain, e.g. marketing, digital, people"
}

variable "account_type" {
    default     = "np"
    description = "sandpit, nonprod, prod"
}

variable "parent_domain" {
    default     = "morconnect.com"
    description = "morconnect.com domain"
}
   
variable "vpc_code" {
    default     = "vpc001"
    description = "Defines default ID of the VPC"
} 
   
variable "application_service" {
    default     = "notification"
    description = "Defines the application service, e.g. common, notification etc."
} 

variable "app_service_short" {
    default     = "notific"
    description = "Defines the application service, e.g. common, notification etc."
    }
    
variable "app_version" {
    default     = "v1"
    description = "Defines the application version, e.g. V1, V2 etc."
    }   
   
variable "seq_id" {
    default     = "001"
    description = "Defines unique number of each component"
} 

variable "q_type" {
    default     = "notification_events"
    description = "purpose of SQS queue"
}