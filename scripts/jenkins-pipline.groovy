pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/your-repo/nextjs-chat-service.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('nextjs-chat-service')
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    docker.withRegistry('https://aws_account_id.dkr.ecr.region.amazonaws.com', 'ecr:aws') {
                        docker.image('nextjs-chat-service').push('latest')
                    }
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    sh 'helm upgrade --install nextjs-chat-service ./helm-chart --namespace default'
                }
            }
        }
    }
}
pipeline {
    agent any
    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/your-repo/nextjs-chat-service.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build('nextjs-chat-service')
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    docker.withRegistry('https://aws_account_id.dkr.ecr.region.amazonaws.com', 'ecr:aws') {
                        docker.image('nextjs-chat-service').push('latest')
                    }
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    sh 'helm upgrade --install nextjs-chat-service ./helm-chart --namespace default'
                }
            }
        }
    }
}
