ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -C "kops-key"
aws s3 cp ~/.ssh/id_rsa.pub s3://final-project-1-k8s-store/kops-key.pub

cd k8s-admin-setup
ansible-playbook -i host.ini install-tools.yml

#create cluster

kops create cluster \
  --name=mycluster.k8s.local \
  --state=s3://final-project-1-k8s-store \
  --zones=us-east-2a,us-east-2b \
  --node-count=2 \
  --node-size=t2.medium \
  --master-size=t2.medium \
  --ssh-public-key="s3://final-project-1-k8s-store/kops-key.pub"
