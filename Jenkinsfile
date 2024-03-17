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
                stash(name: 'packaged_code', includes: 'target/*.war')
            }
        }
        stage('Dockerize') {
            agent {
                label 'Docker'
            }
            steps {
                sh "sudo rm -rf ~/*"
                sh "sudo docker stop JavaAppContainer || true"  // Use "|| true" to prevent pipeline failure if container does not exist
                sh "sudo docker rm JavaAppContainer || true"    // Use "|| true" to prevent pipeline failure if container does not exist
                sh "sudo docker rmi JavaApp || true"           // Use "|| true" to prevent pipeline failure if image does not exist

                sh "export EC2_PUBLIC_IP=\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
                dir("~") {
                    unstash 'packaged_code'
                    sh "sudo docker build -t JavaApp ."
                    sh "sudo docker run -itd -p 8081:8080 --name JavaAppContainer JavaApp"
                    sh "sleep 10"  // Adding a delay to ensure container is started before curling
                    sh "curl http://\$EC2_PUBLIC_IP:8081"
                }
            }
        }
    }
}
