
// pipeline {
//     agent {
//         label 'Maven'
//     }
//     tools {
//         maven 'Maven'
//         jdk 'Java'
//     }
//     environment {
//         DOCKERHUB_CREDENTIALS = credentials('docker_login')
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
//                 stash(name: 'packaged_code', includes: 'target/*.war, Dockerfile')
//             }
//         }
//         stage('Dockerize') {
//             agent {
//                 label 'Docker'
//             }
//             steps {
//                 script {
//                     echo "Deleting all files in folder"
//                     sh "sudo rm -rf *"
                    
//                     // def counter = 1
//                     // try {
//                     //     counter = readFile('counter.txt').toInteger() + 1
//                     // } catch (Exception e) {
//                     //     // If the file doesn't exist, counter will be initialized to 1
//                     // }
//                     // def counter = 1
//                     // try {
//                     //     counter = readFile('counter.txt').toInteger() + 1
//                     //     echo "Counter read from file: $counter"
//                     // } catch (Exception e) {
//                     //     // If the file doesn't exist, counter will be initialized to 1
//                     //     echo "Counter file not found, initializing to 1"
//                     // }
                    
//                     // echo "Counter before Docker build: $counter"
                    
//                     // // Rest of the script

                    
//                     echo "Stopping and removing existing container (if any)"
//                     sh "sudo docker stop java_container || true"  
//                     sh "sudo docker rm java_container || true"    

//                     echo "Removing existing image (if any)"
//                     sh "sudo docker rmi java_app || true"           

//                     echo "Exporting EC2_PUBLIC_IP"
//                     sh "export EC2_PUBLIC_IP=\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"

//                     // dir("~") {
//                     //     echo "Unstashing packaged code"
//                     //     unstash 'packaged_code'
//                     //     sh '''
//                     //         echo "$DOCKERHUB_CREDENTIALS_USR"
//                     //         sudo docker build -t $DOCKERHUB_CREDENTIALS_USR/java_app:$counter .
//                     //         sudo docker login -u "$DOCKERHUB_CREDENTIALS_USR" -p "$DOCKERHUB_CREDENTIALS_PSW"
//                     //         sudo docker push $DOCKERHUB_CREDENTIALS_USR/java_app:$counter
//                     //         sudo docker run -itd -p 8081:8080 --name java_container $DOCKERHUB_CREDENTIALS_USR/java_app:$counter
//                     //     '''
//                     // }
//                     // writeFile file: 'counter.txt', text: counter.toString()
//                     dir("~") {
//                         echo "Unstashing packaged code"
//                         unstash 'packaged_code'
                    
//                         // Initialize counter to 1
//                         def counter = 1
//                         try {
//                             // Attempt to read counter from file and increment it
//                             counter = readFile('counter.txt').toInteger() + 1
//                             echo "Counter read from file: $counter"
//                         } catch (Exception e) {
//                             // If the file doesn't exist or is empty, initialize counter to 1
//                             echo "Counter file not found or empty, initializing to 1"
//                         }
                    
//                         // Perform Docker-related operations
//                         sh """
//                             echo "${DOCKERHUB_CREDENTIALS_USR}"
//                             counter=${counter}
//                             sudo docker build -t ${DOCKERHUB_CREDENTIALS_USR}/java_app:\$counter .
//                             sudo docker login -u "${DOCKERHUB_CREDENTIALS_USR}" -p "${DOCKERHUB_CREDENTIALS_PSW}"
//                             sudo docker push ${DOCKERHUB_CREDENTIALS_USR}/java_app:\$counter
//                             sudo docker run -itd -p 8081:8080 --name java_container ${DOCKERHUB_CREDENTIALS_USR}/java_app:\$counter
//                         """

                    
//                         // Write the updated counter back to the file
//                         writeFile file: 'counter.txt', text: counter.toString()
//                     }

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
    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_login')
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
                        git archive HEAD increment_counter.sh | tar -x
                        mv increment_counter.sh ../
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
                                echo "$DOCKERHUB_CREDENTIALS_USR"
                                sudo docker build -t $DOCKERHUB_CREDENTIALS_USR/java_app:$COUNTER .
                                sudo docker login -u "$DOCKERHUB_CREDENTIALS_USR" -p "$DOCKERHUB_CREDENTIALS_PSW"
                                sudo docker push $DOCKERHUB_CREDENTIALS_USR/java_app:$COUNTER
                                sudo docker run -itd -p 8081:8080 --name java_container $DOCKERHUB_CREDENTIALS_USR/java_app:$COUNTER
                            '''
                        }
                    }

                }
            }
        }
    }
}
