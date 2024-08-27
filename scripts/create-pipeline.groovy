pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-2'
        ECR_REPOSITORY = 'nextjs-app-repo'
        CLUSTER_NAME = 'my-eks-cluster'
        EKS_NAMESPACE = 'default'
        ECR_REPO_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
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
        stage('Login to ECR') {
            steps {
                script {
                    sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com'
                }
            }
        }
        stage('Push Docker Image to ECR') {
            steps {
                script {
                    sh 'docker tag ${ECR_REPO_URI}:${BUILD_ID} ${ECR_REPO_URI}:${BUILD_ID}'
                    sh 'docker push ${ECR_REPO_URI}:${BUILD_ID}'
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
pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-2'
        ECR_REPOSITORY = 'nextjs-app-repo'
        CLUSTER_NAME = 'my-eks-cluster'
        EKS_NAMESPACE = 'default'
        ECR_REPO_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
    }
    stages {
        stage('Lint Code') {
            steps {
                script {
                    sh 'npm install --save-dev eslint'
                    sh 'npx eslint .'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${ECR_REPO_URI}:${env.BUILD_ID}")
                }
            }
        }
        // Continue with remaining stages...
    }
}
def jobName = "CI-Pipeline-Secure"
pipelineJob(jobName) {
    definition {
        cps {
            script """
                pipeline {
                    agent any
                    environment {
                        JENKINS_ADMIN_PASSWORD = credentials('/${env.ENVIRONMENT}/jenkins/admin_password')
                        JENKINS_API_TOKEN = credentials('/${env.ENVIRONMENT}/jenkins/api_token')
                    }
                    stages {
                        stage('Checkout') {
                            steps {
                                git 'https://github.com/your-repo/your-project.git'
                            }
                        }
                        stage('Build') {
                            steps {
                                sh 'echo Building...'
                            }
                        }
                        stage('Test') {
                            steps {
                                sh 'echo Running Tests...'
                            }
                        }
                        stage('Deploy') {
                            steps {
                                sh 'echo Deploying...'
                            }
                        }
                    }
                }
            """.stripIndent()
        }
    }
}

println "Pipeline $jobName has been created with secure credentials from SSM."
