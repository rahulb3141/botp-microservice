pipeline {
    agent any
    

    environment {
        AWS_REGION = "us-east-1"
        ECR_REPO = "941960167356.dkr.ecr.us-east-1.amazonaws.com/eks-webapp"
        BLUE_TAG = "blue"
        GREEN_TAG = "green"
        COLOR_FILE = "active_color.txt"     // file to track current prod color
        KUBECONFIG = "/var/lib/jenkins/.kube/config"

    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/rahulb3141/botp-microservice.git'
            }
        }

        stage('Determine Active Color') {
            steps {
                script {
                    // Track deployment state using a file in Jenkins workspace
                    if (fileExists(COLOR_FILE)) {
                        ACTIVE_COLOR = readFile(COLOR_FILE).trim()
                    } else {
                        ACTIVE_COLOR = "blue"   // default first prod
                        writeFile file: COLOR_FILE, text: ACTIVE_COLOR
                    }
                    echo "Current active color: ${ACTIVE_COLOR}"

                    INACTIVE_COLOR = (ACTIVE_COLOR == "blue") ? "green" : "blue"
                    echo "Deploying to inactive color: ${INACTIVE_COLOR}"

                    // Expose vars globally
                    env.ACTIVE_COLOR = ACTIVE_COLOR
                    env.INACTIVE_COLOR = INACTIVE_COLOR
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = (env.INACTIVE_COLOR == "blue") ? BLUE_TAG : GREEN_TAG
                    sh """
                        docker build -t ${ECR_REPO}:${imageTag} .
                    """
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-credentials']]) {

                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    def imageTag = (env.INACTIVE_COLOR == "blue") ? BLUE_TAG : GREEN_TAG

                    sh """
                        docker push ${ECR_REPO}:${imageTag}
                    """
                }
            }
        }

        stage('Deploy to Inactive Color') {
            steps {
                script {
                    if (env.INACTIVE_COLOR == "blue") {
                        sh "kubectl apply -f k8s/blue/"
                        sh "kubectl apply -f k8s/service.yaml -n blue"
                    } else {
                        sh "kubectl apply -f k8s/green/"
                        sh "kubectl apply -f k8s/service.yaml -n green"
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    def namespace = env.INACTIVE_COLOR
                    echo "Checking pods in namespace ${namespace}"

                    sh """
                        kubectl rollout status deployment/eks-webapp-${namespace} -n ${namespace} --timeout=60s
                    """
                }
            }
        }

        stage('Switch Traffic') {
            steps {
                script {
                    if (env.INACTIVE_COLOR == "blue") {
                        sh """
                            kubectl delete ingress eks-webapp-ingress -n green --ignore-not-found
                            kubectl apply -f k8s/ingress.yaml -n blue
                        """
                    } else {
                        sh """
                            kubectl delete ingress eks-webapp-ingress -n blue --ignore-not-found
                            kubectl apply -f k8s/ingress.yaml -n green
                        """
                    }
                }
            }
        }

        stage('Mark New Active Color') {
            steps {
                script {
                    writeFile file: COLOR_FILE, text: env.INACTIVE_COLOR
                    echo "Updated active color to ${INACTIVE_COLOR}"
                }
            }
        }
    }

    post {
        failure {
            echo "Deployment failed. Rollback may be required."
        }
    }
}
