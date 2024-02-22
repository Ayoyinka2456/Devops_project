pipeline {
    agent {
        label 'maven-node'
    }
    tools {
        maven 'Maven'
        jdk 'Java'
    }
    stages {

        stage('Checkout') {
            steps {
                git branch: 'project-1', url: 'https://github.com/Ayoyinka2456/Devops_project.git'
                // git 'https://github.com/Ayoyinka2456/Jenkins-pipeline1.git'
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
        stage('Deploy to Tomcat') {
            agent {
                label 'Tomcat'
            }
            steps {
                unstash 'packaged_code'
                sh "sudo rm -rf ~/apache*/webapp/*.war"
                sh "sudo mv target/*.war ~/apache*/webapps/"
                sh "sudo ~/apache*/bin/shutdown.sh && sudo ~/apache*/bin/startup.sh"
            }
        }
    }
        post{
            always {
                emailext body: 'Check console output at $BUILD_URL to view the results.', 
                subject: '$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!', 
                to: 'eas.adeyemi@gmail.com'
            }
        }     
    }
