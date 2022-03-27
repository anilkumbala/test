#!/bin/bash

ecs start

# Update packages
sudo yum -y install aws-cli ecs-init nfs-utils awslogs jqecho

# ECS Agent Configuration

echo "ECS_CLUSTER=${ecs_cluster}
ECS_ENGINE_AUTH_TYPE=docker
ECS_LOGLEVEL=warn
ECS_RESERVED_MEMORY=512
ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=5m
ECS_IMAGE_CLEANUP_INTERVAL=10m
ECS_IMAGE_MINIMUM_CLEANUP_AGE=30m" > /etc/ecs/ecs.config

# Stop ECS in order for the changes to take effect.
ecs stop

# Start ECS to bring the agent online and append to cluster.
ecs start