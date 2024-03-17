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
                stash(name: 'packaged_code')
            }
        }
        stage('Dockerize') {
            agent {
                label 'Docker'
            }
            steps {
                echo "Deleting Dockerfile and target folder"
                sh "sudo rm -rf Dockerfile target/"

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

                    echo "Building Docker image"
                    sh "sudo docker build -t java_app ."

                    echo "Running Docker container"
                    sh "sudo docker run -itd -p 8081:8080 --name java_container java_app"
                }
            }
        }
    }
}
