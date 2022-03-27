provider "aws" {
  region = "eu-west-1"
}


################################################
###### IAM - Role                          #####
################################################

resource "aws_iam_role" "ecsrole" {
  name           = "rol-glob-${var.environment}-${var.owner_name}-${var.application_service}Ecs-${var.seq_id}"  
  tags           = var.default_tags
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
	  "ecs.amazonaws.com",
	  "ec2.amazonaws.com"
	]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

output "ecs_iam_role_name" {
  value = aws_iam_role.ecsrole.name
}


################################################
###### IAM - Policy JSON File              #####
################################################

data "template_file" "policy" {
  template = file("${path.module}/policies/ecspolicy.json")
}

################################################
###### IAM - Policy                        #####
################################################

resource "aws_iam_policy" "ecspolicy" {
  name = "pol-glob-${var.environment}-${var.owner_name}-${var.application_service}Ecs-${var.seq_id}"
  policy = data.template_file.policy.rendered
}

################################################
###### IAM - Policy Attachment             #####
################################################

resource "aws_iam_policy_attachment" "ecspolicy-attach" {
  name       = "ecspolicy-attachment"
  #users      = ["${aws_iam_user.user.name}"]
  roles      = [aws_iam_role.ecsrole.name]
  #groups     = aws_iam_group.group.name
  policy_arn = aws_iam_policy.ecspolicy.arn
  depends_on = [
    aws_iam_role.ecsrole
    ]
}

################################################
###### IAM - Instance Profile              #####
################################################

resource "aws_iam_instance_profile" "ecs-instance-profile" {
    name = "ecs-instance-profile-${var.owner_name}-${var.environment}-${var.application_service}Ecs"
    path = "/"
    role = aws_iam_role.ecsrole.name
}

################################################
###### ECS Cluster                         #####
################################################

resource "aws_ecs_cluster" "default" {
    name = "ecs-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}Ecs-${var.seq_id}"
    tags           = var.default_tags
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.default.name
}

/*
resource "aws_ecr_repository" "ecr_repo" {
    name	= "${var.owner_name}/${var.application_service}"
}

output "ecr_repository_name" {
  value = aws_ecr_repository.ecr_repo.name
}
*/

################################################
###### ECS Config File                     #####
################################################

data "template_file" "ecsconfig" {
	template = file("${path.module}/ecsconfig.tpl")
    
    vars = {
    ecs_cluster = aws_ecs_cluster.default.name
    }	
}

################################################
###### Launch Configuration                #####
################################################

resource "aws_launch_configuration" "ecs-launch-configuration" {
    name                        = "lcg-${var.region_code}-${var.environment}-${var.owner_name}-vpc${var.seq_id}-${var.application_service}Ecs-${var.seq_id}"
    
    image_id                    = var.ami
    instance_type               = var.instance_class
    iam_instance_profile        = aws_iam_instance_profile.ecs-instance-profile.name
    root_block_device {
		volume_type = "standard"
		delete_on_termination = true
	} 
	ebs_block_device {
		device_name = "/dev/xvdcz"
		volume_type = "standard"
		encrypted = true
	}
	lifecycle {
		create_before_destroy = true
	}
	security_groups             = [aws_security_group.marketing-cluster-sg.id]
	associate_public_ip_address = "false"
	key_name                    = var.ecs_key_pair
	user_data = data.template_file.ecsconfig.rendered
}


################################################
###### Autoscaling Group                   #####
################################################

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
    name                        = "asg-${var.region_code}-${var.environment}-${var.owner_name}-vpc${var.seq_id}-${var.application_service}Ecs-${var.seq_id}"
    max_size                    = "3"
    min_size                    = "1"
    desired_capacity            = "2"
    vpc_zone_identifier         = var.subnet_ids
    launch_configuration        = aws_launch_configuration.ecs-launch-configuration.name
    enabled_metrics             = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
    health_check_type           = "ELB"
    protect_from_scale_in       = "false"
    
    tag {
    key                         = "Name"
    value                       = "ec2-${var.region_code}-${var.environment}-${var.owner_name}-${var.vpc_code}-${var.application_service}Ecs-${var.seq_id}"
    propagate_at_launch         = true
    }
    
    tag {
    key                         = "Domain"
    value                       = "marketing"
    propagate_at_launch         = true
    }
    
    tag {
    key                         = "Domain_Short"
    value                       = "mktg"
    propagate_at_launch         = true
    }
    
    tag {
    key                         = "Environment"
    value                       = "nonprod"
    propagate_at_launch         = true
    }
    
    tag {
    key                         = "Region"
    value                       = "eu-west-1"
    propagate_at_launch         = true
    }
    
    tag {
    key                         = "Region_code"
    value                       = "euw1"
    propagate_at_launch         = true
    }        
		
    tag {
    key                         = "Service"
    value                       = "shared"
    propagate_at_launch         = true
    }  
 }
  
  resource "aws_autoscaling_policy" "scale-up" {
  name                   = "asp-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsScaleUp-${var.seq_id}"
  
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ecs-autoscaling-group.name
}

resource "aws_autoscaling_policy" "scale-down" {
  name                   = "asp-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsScaleDown-${var.seq_id}"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ecs-autoscaling-group.name
}

resource "aws_autoscaling_schedule" "daily_scale_down" {
    scheduled_action_name  = "Scheduled-DailyScaleDown"
    min_size               = 0
    max_size               = 0
    desired_capacity       = 0
    recurrence             = "0 19 * * MON-FRI"
    autoscaling_group_name = aws_autoscaling_group.ecs-autoscaling-group.name
}

resource "aws_autoscaling_schedule" "daily_scale_up" {
  scheduled_action_name  = "Scheduled-DailyScaleUp"
  min_size               = "1"
  max_size               = "3"
  desired_capacity       = "1"
  recurrence             = "0 6 * * MON-FRI"
  autoscaling_group_name = aws_autoscaling_group.ecs-autoscaling-group.name
}

################################################
###### SNS Topics                          #####
################################################

resource "aws_sns_topic" "warn" {
  name = "sns-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsWarn-${var.seq_id}"
  tags = merge(
  { 
	Application = var.application_service
  }, 
    var.default_tags
  )
}

output "ecs_sns_topic_warn_name" {
  value = aws_sns_topic.warn.name
}

resource "aws_sns_topic" "error" {
  name = "sns-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsError-${var.seq_id}"
  tags = merge(
  { 
	Application = var.application_service
  }, 
    var.default_tags
  )
}

output "ecs_sns_topic_error_name" {
  value = aws_sns_topic.error.name
}

resource "aws_sns_topic" "info" {
  name = "sns-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsInfo-${var.seq_id}"
  tags = merge(
  { 
	Application = var.application_service
  }, 
    var.default_tags
  )
}

output "ecs_sns_topic_info_name" {
  value = aws_sns_topic.info.name
}

################################################
###### Cloudwatch Log Group                #####
################################################

resource "aws_cloudwatch_log_group" "ecs-log-group" {
  name = "clg-${var.environment}-${var.owner_name}-${var.application_service}ecs-${var.seq_id}"
  
  retention_in_days = 30
}  

output "ecs_cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.ecs-log-group.name
}
  
################################################
###### Cloudwatch Metrics for Auto-Scaling #####
################################################ 
  
  
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsCPUUtilizationHigh-${var.seq_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"   #GreaterThanOrEqualToThreshold, GreaterThanThreshold, LessThanThreshold, LessThanOrEqualToThreshold.
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization" #CPUReservation CPUUtilization MemoryReservation MemoryUtilization
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "80"
  
  dimensions = {
  ClusterName         = aws_ecs_cluster.default.name
  }
  
  alarm_description = "Scale up if the cpu utilisation is above 80% for 5 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale-up.arn]

  lifecycle {
    create_before_destroy = true
  }
}
  
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_low" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsCPUUtilizationLow-${var.seq_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "20"

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
  }

  alarm_description = "Scale down if the cpu utilisation is below 20% for 5 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale-down.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_reservation_high" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsCPUReservationHigh-${var.seq_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "80"

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
  }
  
  alarm_description = "Scale up if the CPU reservation is above 80% for 5 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale-up.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_reservation_low" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsCPUReservationLow-${var.seq_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "20"

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
  }
  
  alarm_description = "Scale down if the cpu reservation is below 20% for 5 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale-down.arn]
  

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsMemoryUtilizationHigh-${var.seq_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "80"

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
  }
  
  alarm_description = "Scale up if the memory reservation is above 80% for 5 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale-up.arn]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_low" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsMemoryUtilizationLow-${var.seq_id}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "20"

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
  }

alarm_description = "Scale down if the memory utilisation is below 20% for 5 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale-down.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_reservation_high" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsMemoryReservationHigh-${var.seq_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "80"

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
  }
  
  alarm_description = "Scale up if the memory reservation is above 80% for 5 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale-up.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_reservation_low" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsMemoryReservationLow-${var.seq_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "20"

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
  }
  
  alarm_description = "Scale down if the memory reservation is below 20% for 5 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale-down.arn]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_group_max_size" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsAsgMaxSize-${var.seq_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "GroupMaxSize"
  namespace           = "AWS/AutoScaling"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "3"

  dimensions = {
    AutoScalingGroupName = aws_ecs_cluster.default.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_group_pending_instances" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsAsgPendingInstances-${var.seq_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "GroupPendingInstances"
  namespace           = "AWS/AutoScaling"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"

  dimensions = {
    AutoScalingGroupName = aws_ecs_cluster.default.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_group_terminating_instances" {
  alarm_name          = "cla-${var.region_code}-${var.environment}-${var.owner_name}-${var.application_service}EcsAsgTerminatingInstances-${var.seq_id}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "GroupTerminatingInstances"
  namespace           = "AWS/AutoScaling"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"

  dimensions = {
    AutoScalingGroupName = aws_ecs_cluster.default.name
  }

  lifecycle {
    create_before_destroy = true
  }
  }


################################################
###### Security Group                      #####
################################################

resource "aws_security_group" "marketing-cluster-sg" {
  name              = "sgr-${var.region_code}-${var.environment}-${var.owner_name}-vpc${var.seq_id}-${var.application_service}ecs-${var.seq_id}"
  tags           = var.default_tags
  
  description = "Default sg for ECS Cluster in loyalty"
  vpc_id = var.vpc


ingress {
    # TLS (change to whatever ports you need)
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["10.249.64.0/19"]
  }
  
  ingress {
    # TLS (change to whatever ports you need)
    from_port   = 10000
    to_port     = 60000
    protocol    = "TCP"
    cidr_blocks = ["10.249.64.0/19"]
  }
  
  egress {
    # TLS (change to whatever ports you need)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

