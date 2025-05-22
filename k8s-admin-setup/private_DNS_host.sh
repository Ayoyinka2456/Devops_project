VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=final-project-1-vpc" --query "Vpcs[0].VpcId" --output text)

aws route53 create-hosted-zone \
  --name final-project-1-k8s-cluster.local \
  --caller-reference "$(date +%s)" \
  --hosted-zone-config PrivateZone=true \
  --vpc VPCRegion=us-east-2,VPCId=$VPC_ID
