pipeline {
    agent {
        label 'Jenkins_Server'  // Node label where Docker is available
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_login') // Jenkins credentials ID
        javaAppName = "java_app_5_25"
        DOCKER_IMAGE = "${DOCKERHUB_CREDENTIALS_USR}/${javaAppName}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cleaning workspace..."
                sh "whoami"
                sh "sudo rm -rf *"
                sh "ls && pwd"
                git branch: 'project-1', url: 'https://github.com/Ayoyinka2456/Devops_project.git'
            }
        }

        stage('Restore Counter') {
            steps {
                script {
                    echo "Looking for archived counter.txt from previous build..."
                    copyArtifacts(
                        projectName: env.JOB_NAME,
                        selector: [$class: 'StatusBuildSelector', stable: true],
                        filter: 'counter.txt',
                        optional: true
                    )
                }
            }
        }

        stage('Dockerize') {
            steps {
                script {
                    def counterFile = "${env.WORKSPACE}/counter.txt"
                    def counter = 0
                    // If file exists, read and increment
                    if (fileExists(counterFile)) {
                        counter = readFile(counterFile).trim().toInteger()
                        echo "Incremented counter: ${counter}"
                    } else {
                        echo "No existing counter file. Starting at 0."
                    }

                    def imageTag = "${DOCKER_IMAGE}:${counter}"
                    echo "Using Docker image tag: ${imageTag}"

                    // Build and push
                    sh "docker build -t ${imageTag} ."
                    sh "docker login -u \"${DOCKERHUB_CREDENTIALS_USR}\" -p \"${DOCKERHUB_CREDENTIALS_PSW}\""
                    sh "docker push ${imageTag}"

                    // Stash BEFORE incrementing
                    writeFile file: 'counter.txt', text: counter.toString()
                    stash includes: 'counter.txt', name: 'counter-file'

                    // Increment only after success
                    // Save tag and persist counter
                    writeFile file: 'counter.txt', text: (counter + 1).toString()
                }
            }
        }

        stage('Tomcat') {
            agent {
                label 'Tomcat'
            }
            steps {
                unstash 'counter-file'

                script {
                    // Read the image tag from counter.txt
                    env.IMAGE_TAG = readFile('counter.txt').trim()
                    echo "Deploying Docker image: ${DOCKER_IMAGE}:${env.IMAGE_TAG}"
                }

                sh '''
                    sudo yum -y install docker
                    sudo systemctl start docker
                    sudo systemctl enable docker
                    sudo systemctl status docker --no-pager
                '''

                sh """
                    sudo docker container stop java_container || true
                    sudo docker container rm java_container || true
                    sudo docker run -itd -p 8081:8080 --name java_container ${DOCKER_IMAGE}:${env.IMAGE_TAG}
                """

                writeFile file: 'counter.txt', text: env.IMAGE_TAG
                stash includes: 'counter.txt', name: 'counter-file'
            }
        }

        stage('Terraform') {
            agent {
                label 'Terraform'
            }
            steps {
                unstash 'counter-file'

                script {
                    // Read the image tag from counter.txt
                    env.IMAGE_TAG = readFile('counter.txt').trim()
                    echo "Provisioning Ansible-master & K8s-workstation --> container: ${DOCKER_IMAGE}:${env.IMAGE_TAG}"
                }

                sh """
                    echo "Entering Terraform"
                    if [ -d "Devops_project" ]; then
                      echo "Devops_project directory exists"
                      cd Devops_project
                      terraform destroy -auto-approve && rm -f terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
                      sleep 60
                      cd ../ && rm -rf Devops_project
                      git clone -b project-3 https://github.com/Ayoyinka2456/Devops_project.git
                      cd Devops_project
                    else
                      echo "Devops_project directory does not exist"
                      git clone -b project-3 https://github.com/Ayoyinka2456/Devops_project.git
                      cd Devops_project/
                    fi
                    echo "Current Directory:"
                    pwd
                    ls -la k8s-admin-setup/

                    terraform init
                    terraform apply -auto-approve
                    echo "Waiting 300 seconds after terraform apply..."
                    sleep 300

                    ANSIBLE_IP=\$(terraform output -raw ansible_master_public_ip)
                    K8S_IP=\$(terraform output -raw k8s_workstation_public_ip)

                    chmod 400 k8s-admin-setup/devops_1.pem

                    scp -o StrictHostKeyChecking=no -i "k8s-admin-setup/devops_1.pem" -r \${WORKSPACE}/Devops_project/k8s-admin-setup ec2-user@\${ANSIBLE_IP}:/home/ec2-user/
                    scp -o StrictHostKeyChecking=no -i "k8s-admin-setup/devops_1.pem" \${WORKSPACE}/counter.txt ec2-user@\${ANSIBLE_IP}:/home/ec2-user/

                    echo "SSHing into Ansible-Master for setup..."
                    ssh -i "k8s-admin-setup/devops_1.pem" -o StrictHostKeyChecking=no ec2-user@\${ANSIBLE_IP} <<'ENDSSH'
sudo yum -y install epel-release
sudo yum -y install ansible
ansible --version

export counter=\$(xargs < counter.txt)

cd /home/ec2-user/k8s-admin-setup/
chmod 400 devops_1.pem
chmod +x install_python3.sh
./install_python3.sh
python3 render.py

ansible-playbook -i host.ini 01-* && \
sleep 30 && \
ansible-playbook -i host.ini 02-* && \
ansible-playbook -i host.ini 03-* && \
ansible-playbook -i host.ini 04-*
ENDSSH

                    echo "Back to Terraform server"
                    pwd
                """
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'counter.txt', fingerprint: true
            echo "counter.txt archived for next build."
        }
        failure {
            echo "Build failed. Please check the logs."
        }
    }
}
