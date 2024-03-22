// pipeline {
//     agent {
//         label 'Maven'
//     }
//     tools {
//         maven 'Maven'
//         jdk 'Java'
//     }
//     stages {
//         stage('Checkout') {
//             steps {
//                 git branch: 'test', url: 'https://github.com/Ayoyinka2456/Devops_project.git'
//             }
//         }
//         stage('Build') {
//             steps {
//                 sh 'mvn clean install'
//             }
//         }
//         stage('Test') {
//             steps {
//                 sh 'mvn test'
//                 stash(name: 'packaged_code')
//             }
//         }
//         stage('Dockerize') {
//             agent {
//                 label 'Docker'
//             }
//             steps {
//                 echo "Deleting Dockerfile and target folder"
//                 sh "sudo rm -rf Dockerfile target/"

//                 echo "Stopping and removing existing container (if any)"
//                 sh "sudo docker stop java_container || true"  
//                 sh "sudo docker rm java_container || true"    

//                 echo "Removing existing image (if any)"
//                 sh "sudo docker rmi java_app || true"           

//                 echo "Exporting EC2_PUBLIC_IP"
//                 sh "export EC2_PUBLIC_IP=\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"

//                 dir("~") {
//                     echo "Unstashing packaged code"
//                     unstash 'packaged_code'

//                     echo "Building Docker image"
//                     sh "sudo docker build -t java_app ."

//                     echo "Running Docker container"
//                     sh "sudo docker run -itd -p 8081:8080 --name java_container java_app"
//                 }
//             }
//         }
//     }
// }




pipeline {
    agent {
        label 'Maven'
    }
    tools {
        maven 'Maven'
        jdk 'Java'
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'test', url: 'https://github.com/Ayoyinka2456/Devops_project.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
                stash(name: 'packaged_code', includes: 'target/*.war, Dockerfile')
            }
        }
        stage('Dockerize') {
            agent {
                label 'Docker'
            }
            steps {
                script {
                    echo "Deleting all files in folder"
                    sh "sudo rm -rf *"

                    echo "Import specific files from repo"
                    def gitCloneOutput = sh(script: '''
                        git clone -b test --single-branch https://github.com/Ayoyinka2456/Devops_project.git temp_folder
                        cd temp_folder
                        git archive HEAD increment_counter.sh docker_login.sh | tar -x
                        mv increment_counter.sh ../
                        mv docker_login.sh ../
                        cd ../
                        rm -rf temp_folder
                    ''', returnStdout: true).trim()

                    if (gitCloneOutput.contains("fatal") || gitCloneOutput.contains("error")) {
                        error "Failed to import specific files from the repository. Details: $gitCloneOutput"
                    }

                    echo "Stopping and removing existing container (if any)"
                    sh "sudo docker stop java_container || true"  
                    sh "sudo docker rm java_container || true"    

                    echo "Removing existing image (if any)"
                    sh "sudo docker rmi java_app || true"           

                    echo "Exporting EC2_PUBLIC_IP"
                    sh "export EC2_PUBLIC_IP=\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"

                    dir("~") {
                        echo "Unstashing packaged code"
                        unstash 'packaged_code'

                        script {
                            sh '''
                                sudo chmod +x /home/centos/workspace/BasicJavaDeployment/increment_counter.sh && source /home/centos/workspace/BasicJavaDeployment/increment_counter.sh
                                sudo chmod +x /home/centos/workspace/BasicJavaDeployment/docker_login.sh && source /home/centos/workspace/BasicJavaDeployment/docker_login.sh
                                sudo docker build -t $DOCKER_USERNAME/java_app:$COUNTER .
                                sudo docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PSWD"
                                sudo docker push $DOCKER_USERNAME/java_app:$COUNTER
                                sudo docker run -itd -p 8081:8080 --name java_container $DOCKER_USERNAME/java_app:$COUNTER
                            '''
                        }
                    }

                }
            }
        }
    }
}
