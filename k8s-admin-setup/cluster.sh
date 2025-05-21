#!/bin/bash

# Get Subnet ID by tag name
SUBNET_ID=$(aws ec2 describe-subnets \
  --filters "Name=tag:Name,Values=final-project-1-public-subnet" \
  --query "Subnets[0].SubnetId" \
  --output text)

# Create K8s cluster
kops create cluster \
  --name=final-project-1-k8s-cluster.local \
  --state=s3://final-project-1-k8s-store \
  --cloud=aws \
  --zones=us-east-2a \
  --topology=public \
  --networking=calico \
  --network-cidr=10.1.0.0/16 \
  --subnets=$SUBNET_ID \
  --node-size=t2.medium \
  --control-plane-size=t2.medium \
  --node-count=2 \
  --ssh-public-key=~/.ssh/id_rsa.pub
