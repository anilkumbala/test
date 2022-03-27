variable "default_tags" { 
    type = map 
    default = { 
        Domain:             "marketing"
        Domain_Short:       "mktg"
		Environment:        "dev"
		Service:            "basketgatewaystub"
        Service_Short:      "bgwaystub"
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
    default     = "n"
    description = "n for nonprod, p for prod"
}
   
variable "owner_name" {
    default     = "marketing"
    description = "business owner domain, e.g. marketing, digital, people"
} 
   
variable "vpc_code" {
    default     = "vpc001"
    description = "Defines default ID of the VPC"
} 
   
variable "application_service" {
    default     = "basketgatewaystub"
    description = "Defines the application service, e.g. common, notification etc."
} 
   
variable "seq_id" {
    default     = "001"
    description = "Defines unique number of each component"
} 