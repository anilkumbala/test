variable "instance_class" {
  default     = "c5.large"
  description = "Default EC2 Instance Class for ECS Clusters"
}

variable "cap_provider" {
    default   = "ECS"
    description = "Default capacity provider for Containers - either ECS or Fargate"
}

variable "vpc" {
    default   = "vpc-0669b48a28ea475f4"
    description = "Default VPC for Morrisons Infrastructure"
}

variable "ami" {
  default     = "ami-0fc0477ac55200d28"
  description = "Default AMI for ECS Cluster Instances"
}

variable "ecs_key_pair" {
  default     = "CLOUDPLATFORMTEAM"
  description = "Default Key Pair for EC2 Instances"
}

variable "subnet_ids" {
    default     = ["subnet-055da8be69fdd1ab1", "subnet-0c45354de908defc2", "subnet-0d9cd19113c8cb685"]
    description = "Private Subnet IDs for ECS Subnets"
}

variable "public_subnet_ids" {
    default     = ["subnet-087df08cd4e943557", "subnet-0293ceb7829e3ecfc", "subnet-01fb7da87756a8d87"]
    description = "Public Subnet IDs for ECS Subnets"
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
    description = "Defines the application service, e.g. common, notification etc."
} 
   
variable "seq_id" {
    default     = "001"
    description = "Defines unique number of each component"
} 

variable "default_tags" { 
    type = map 
    default = { 
        Domain:             "marketing"
        Domain_Short:       "mktg"
		Environment:        "nonprod"
        Region:             "eu-west-1"
        Region_code:        "euw1"
        } 
}

