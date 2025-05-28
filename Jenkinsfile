// pipeline {
//     agent {
//         label 'Jenkins_Server'
//     }

//     environment {
//         DOCKERHUB_CREDENTIALS = credentials('docker_login')
//         javaAppName = "java_app_5_25"
//         DOCKER_IMAGE = "${DOCKERHUB_CREDENTIALS_USR}/${javaAppName}"
//     }

//     stages {
//         stage('Checkout') {
//             steps {
//                 echo "Cleaning workspace..."
//                 sh "whoami"
//                 sh "sudo rm -rf *"
//                 sh "ls && pwd"
//                 git branch: 'project-1', url: 'https://github.com/Ayoyinka2456/Devops_project.git'
//             }
//         }

//         stage('Restore Artifacts') { // UPDATED NAME
//             steps {
//                 script {
//                     echo "Restoring artifacts from previous successful build..."
//                     copyArtifacts(
//                         projectName: env.JOB_NAME,
//                         selector: [$class: 'StatusBuildSelector', stable: true],
//                         filter: 'counter.txt, K8S_IP.txt', // UPDATED TO INCLUDE K8S_IP
//                         optional: true
//                     )
//                 }
//             }
//         }

//         stage('Dockerize') {
//             steps {
//                 script {
//                     def counterFile = "${env.WORKSPACE}/counter.txt"
//                     def counter = 0
//                     if (fileExists(counterFile)) {
//                         counter = readFile(counterFile).trim().toInteger()
//                         echo "Incremented counter: ${counter}"
//                     } else {
//                         echo "No existing counter file. Starting at 0."
//                     }

//                     def imageTag = "${DOCKER_IMAGE}:${counter}"
//                     echo "Using Docker image tag: ${imageTag}"

//                     sh "docker build -t ${imageTag} ."
//                     sh "docker login -u \"${DOCKERHUB_CREDENTIALS_USR}\" -p \"${DOCKERHUB_CREDENTIALS_PSW}\""
//                     sh "docker push ${imageTag}"

//                     writeFile file: 'counter.txt', text: counter.toString()
//                     stash includes: 'counter.txt', name: 'counter-file'
//                     writeFile file: 'counter.txt', text: (counter + 1).toString()
//                 }
//             }
//         }

//         stage('Tomcat') {
//             agent {
//                 label 'Tomcat'
//             }
//             steps {
//                 unstash 'counter-file'

//                 script {
//                     env.IMAGE_TAG = readFile('counter.txt').trim()
//                     echo "Deploying Docker image: ${DOCKER_IMAGE}:${env.IMAGE_TAG}"
//                 }

//                 sh '''
//                     sudo yum -y install docker
//                     sudo systemctl start docker
//                     sudo systemctl enable docker
//                     sudo systemctl status docker --no-pager
//                 '''

//                 sh """
//                     sudo docker container stop java_container || true
//                     sudo docker container rm java_container || true
//                     sudo docker run -itd -p 8081:8080 --name java_container ${DOCKER_IMAGE}:${env.IMAGE_TAG}
//                 """

//                 writeFile file: 'counter.txt', text: env.IMAGE_TAG
//                 stash includes: 'counter.txt', name: 'counter-file'
//             }
//         }

//         stage('Terraform') {
//             agent {
//                 label 'Terraform'
//             }
//             steps {
//                 unstash 'counter-file'
        
//                 script {
//                     env.IMAGE_TAG = readFile('counter.txt').trim()
        
//                     // BEGIN ADDED CLEANUP BLOCK
//                     if (fileExists('K8S_IP.txt')) {
//                         env.K8S_IP = readFile('K8S_IP.txt').trim()
//                         echo "Loaded previous K8S_IP: ${env.K8S_IP}"
        
//                         sh """
//                             echo "Cleaning up previous K8s workstation..."
//                             ssh -o StrictHostKeyChecking=no -i Devops_project/k8s-admin-setup/devops_1.pem ec2-user@${env.K8S_IP} <<'ENDSSH'
//                                 echo "Connected to K8s workstation: \$(hostname)"
//                                 if command -v kubectl &> /dev/null; then
//                                     kubectl delete all --all || true
//                                 else
//                                     echo "kubectl not found on remote instance."
//                                 fi
//                             ENDSSH
//                         """
//                     } else {
//                         echo "No K8S_IP.txt found, skipping K8s cleanup."
//                     }
//                     // END ADDED CLEANUP BLOCK
        
//                     sh '''
//                         echo "Entering Terraform"
//                         if [ -d "Devops_project" ]; then
//                             cd Devops_project
//                             terraform destroy -auto-approve && rm -f terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
//                             sleep 60
//                             cd ../ && rm -rf Devops_project
//                             git clone -b project-3 https://github.com/Ayoyinka2456/Devops_project.git
//                             cd Devops_project
//                         else
//                             git clone -b project-3 https://github.com/Ayoyinka2456/Devops_project.git
//                             cd Devops_project/
//                         fi
//                         terraform init
//                         terraform apply -auto-approve
//                         sleep 300
        
//                         ANSIBLE_IP=$(terraform output -raw ansible_master_public_ip)
//                         K8S_IP=$(terraform output -raw k8s_workstation_public_ip)
        
//                         echo "$ANSIBLE_IP" > ANSIBLE_IP.txt
//                         echo "$K8S_IP" > K8S_IP.txt
//                         chmod 400 k8s-admin-setup/devops_1.pem
        
//                         scp -o StrictHostKeyChecking=no -i k8s-admin-setup/devops_1.pem -r ${WORKSPACE}/Devops_project/k8s-admin-setup ec2-user@${ANSIBLE_IP}:/home/ec2-user/
//                         scp -o StrictHostKeyChecking=no -i k8s-admin-setup/devops_1.pem ${WORKSPACE}/counter.txt ec2-user@${ANSIBLE_IP}:/home/ec2-user/k8s-admin-setup
        
//                         ssh -i "k8s-admin-setup/devops_1.pem" -o StrictHostKeyChecking=no ec2-user@${ANSIBLE_IP} <<'ENDSSH'
//                             sudo yum -y install epel-release
//                             sudo yum -y install ansible
//                             export counter=\$(xargs < counter.txt)
//                             cd /home/ec2-user/k8s-admin-setup/
//                             chmod 400 devops_1.pem
//                             chmod +x install_python3.sh
//                             ./install_python3.sh
//                             ansible-playbook -i host.ini 01-* && \
//                             sleep 30 && \
//                             python3 render.py
//                             ansible-playbook -i host.ini 02-* && \
//                             ansible-playbook -i host.ini 03-* && \
//                             ansible-playbook -i host.ini 04-*
//                         ENDSSH
//                     '''
//                 }
//             }
//         }


//     post {
//         success {
//             archiveArtifacts artifacts: 'counter.txt, K8S_IP.txt, ANSIBLE_IP.txt', fingerprint: true // UPDATED
//             echo "Artifacts archived for next build."
//         }
//         failure {
//             echo "Build failed. Please check the logs."
//         }
//     }
// }


pipeline {
    agent {
        label 'Jenkins_Server'
    }

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_login')
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

        stage('Restore Artifacts') { // UPDATED NAME
            steps {
                script {
                    echo "Restoring artifacts from previous successful build..."
                    copyArtifacts(
                        projectName: env.JOB_NAME,
                        selector: [$class: 'StatusBuildSelector', stable: true],
                        filter: 'counter.txt, K8S_IP.txt', // UPDATED TO INCLUDE K8S_IP
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
                    if (fileExists(counterFile)) {
                        counter = readFile(counterFile).trim().toInteger()
                        echo "Incremented counter: ${counter}"
                    } else {
                        echo "No existing counter file. Starting at 0."
                    }

                    def imageTag = "${DOCKER_IMAGE}:${counter}"
                    echo "Using Docker image tag: ${imageTag}"

                    sh "docker build -t ${imageTag} ."
                    sh "docker login -u \"${DOCKERHUB_CREDENTIALS_USR}\" -p \"${DOCKERHUB_CREDENTIALS_PSW}\""
                    sh "docker push ${imageTag}"

                    writeFile file: 'counter.txt', text: counter.toString()
                    stash includes: 'counter.txt', name: 'counter-file'
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
                    env.IMAGE_TAG = readFile('counter.txt').trim()

                    // BEGIN ADDED CLEANUP BLOCK
                    if (fileExists('Devops_project/K8S_IP.txt')) {
                        env.K8S_IP = readFile('Devops_project/K8S_IP.txt').trim()
                        echo "Loaded previous K8S_IP: ${env.K8S_IP}"

                        sh '''
                            echo "Cleaning up previous K8s workstation..."
                            ssh -o StrictHostKeyChecking=no -i Devops_project/k8s-admin-setup/devops_1.pem ec2-user@${K8S_IP} <<'ENDSSH'
echo "Connected to K8s workstation"
if command -v kubectl &> /dev/null; then
    sudo kubectl delete all --all || true
    sleep 180
else
    echo "kubectl not found on remote instance."
fi
ENDSSH
                        '''
                    } else {
                        echo "No K8S_IP.txt found, skipping K8s cleanup."
                    }
                    // END ADDED CLEANUP BLOCK

                    sh '''
                        echo "Entering Terraform"
                        if [ -d "Devops_project" ]; then
                            cd Devops_project
                            terraform destroy -auto-approve && rm -f terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
                            sleep 60
                            cd ../ && rm -rf Devops_project
                            git clone -b project-3 https://github.com/Ayoyinka2456/Devops_project.git
                            cd Devops_project
                        else
                            git clone -b project-3 https://github.com/Ayoyinka2456/Devops_project.git
                            cd Devops_project/
                        fi
                        terraform init
                        terraform apply -auto-approve
                        sleep 300

                        ANSIBLE_IP=$(terraform output -raw ansible_master_public_ip)
                        K8S_IP=$(terraform output -raw k8s_workstation_public_ip)

                        echo "$ANSIBLE_IP" > ANSIBLE_IP.txt
                        echo "$K8S_IP" > K8S_IP.txt
                        chmod 400 k8s-admin-setup/devops_1.pem

                        scp -o StrictHostKeyChecking=no -i k8s-admin-setup/devops_1.pem -r ${WORKSPACE}/Devops_project/k8s-admin-setup ec2-user@${ANSIBLE_IP}:/home/ec2-user/
                        scp -o StrictHostKeyChecking=no -i k8s-admin-setup/devops_1.pem ${WORKSPACE}/counter.txt ec2-user@${ANSIBLE_IP}:/home/ec2-user/k8s-admin-setup

                        ssh -i "k8s-admin-setup/devops_1.pem" -o StrictHostKeyChecking=no ec2-user@${ANSIBLE_IP} <<'ENDSSH'
sudo yum -y install epel-release
sudo yum -y install ansible
export counter=$(xargs < counter.txt)
cd /home/ec2-user/k8s-admin-setup/
chmod 400 devops_1.pem
chmod +x install_python3.sh
./install_python3.sh
ansible-playbook -i host.ini 01-* && \
sleep 30 && \
python3 render.py
ansible-playbook -i host.ini 02-* && \
ansible-playbook -i host.ini 03-* && \
ansible-playbook -i host.ini 04-*
ENDSSH
                    '''
                }
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'counter.txt, K8S_IP.txt, ANSIBLE_IP.txt', fingerprint: true // UPDATED
            echo "Artifacts archived for next build."
        }
        failure {
            echo "Build failed. Please check the logs."
        }
    }
}
