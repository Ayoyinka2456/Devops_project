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

        stage('Dockerize') {
            steps {
                script {
                    sh "sudo docker ps -a"
                    sh "sudo docker images ls -a"
                    sh "whoami"
                    echo ${DOCKERHUB_CREDENTIALS_USR}
                    echo ${DOCKERHUB_CREDENTIALS_PSW}
                    echo "Im here"


                    
                    echo "Stopping and removing any old container named java_container"
                    sh "docker stop java_container || true"
                    sh "docker rm java_container || true"

                    echo "Removing old Docker image if it exists"
                    sh "docker rmi ${DOCKER_IMAGE} || true"

                    // Initialize and read build counter
                    def counter = 1
                    try {
                        counter = readFile('counter.txt').toInteger() + 1
                        echo "Read existing counter: ${counter}"
                    } catch (Exception e) {
                        echo "Counter file not found. Starting from 1."
                    }

                    // Build, push, and run Docker image
                                        
                    sh """
                        echo "Dockerhub Username: ${DOCKERHUB_CREDENTIALS_USR}"
                        echo "Building Docker Image with tag: ${DOCKER_IMAGE}:${counter}"

                        docker build -t ${DOCKER_IMAGE}:${counter} .

                        echo "Pushing image to DockerHub..."
                        docker login -u "${DOCKERHUB_CREDENTIALS_USR}" -p "${DOCKERHUB_CREDENTIALS_PSW}"
                        docker push ${DOCKER_IMAGE}:${counter}
                    """

                    // Save updated counter for reuse in Deploy stage
                    writeFile file: 'counter.txt', text: counter.toString()
                }
            }
        }

        stage('Deploy') {
            agent {
                label 'Tomcat'  // Run this stage on a Tomcat-labeled agent
            }
            steps {
                script {
                    env.IMAGE_TAG = readFile('counter.txt').trim()
                }
                echo "Deploying Docker image: ${DOCKER_IMAGE}:${env.IMAGE_TAG}"
                sh """
                    sudo docker run -itd -p 8081:8080 --name java_container ${DOCKER_IMAGE}:${env.IMAGE_TAG}
                """
            }
        }
    }
}
