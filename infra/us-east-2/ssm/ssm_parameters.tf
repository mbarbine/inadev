pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-2'
        ECR_REPOSITORY = 'nextjs-app-repo'
        CLUSTER_NAME = 'my-eks-cluster'
        EKS_NAMESPACE = 'default'
        ECR_REPO_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
        MY_SECRET_KEY = sh(script: 'aws ssm get-parameter --name /path/to/secret --with-decryption --region us-east-2 --query Parameter.Value --output text', returnStdout: true).trim()
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/your-org/nextjs-app.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${ECR_REPO_URI}:${env.BUILD_ID}")
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    sh '''
                    kubectl set image deployment/nextjs nextjs=${ECR_REPO_URI}:${BUILD_ID} -n ${EKS_NAMESPACE}
                    '''
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
