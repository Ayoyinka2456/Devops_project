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
                git 'https://github.com/Ayoyinka2456/Devops_project.git'
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
                sh "sudo docker stop JavaAppContainer && sudo docker rm JavaAppContainer"
                sh "sudo docker rmi JavaApp"

                sh "export EC2_PUBLIC_IP=\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
                sh "cd ~/"
                unstash 'packaged_code'
                sh "wget 'https://github.com/Ayoyinka2456/Devops_project/blob/test/Dockerfile'"
                sh "sudo mv target/*.war ~/"
                sh "sudo docker build -t JavaApp ."
                sh "sudo docker run -itd -p 8081:8080 --name JavaAppContainer JavaApp"
                sh "curl http://$EC2_PUBLIC_IP:8081"
            }
        }
    }    
}
