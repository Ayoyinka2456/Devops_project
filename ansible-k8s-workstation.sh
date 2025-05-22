
cd k8s-admin-setup
ansible-playbook -i host.ini install_tools.yml


#ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -C "kops-key"
#aws s3 cp ~/.ssh/id_rsa.pub s3://final-project-1-k8s-store/kops-key.pub

#create cluster

# kops create cluster \
#   --name=final-project-1-k8s-cluster.local \
#   --state=s3://final-project-1-k8s-store \
#   --zones=us-east-2a,us-east-2b \
#   --node-count=2 \
#   --node-size=t2.medium \
#   --control-plane-size=t2.medium \
#   --ssh-public-key="~/.ssh/id_rsa.pub"
