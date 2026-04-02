pipeline {
    agent any
    
    environment {
        AWS_REGION = "us-east-1"
        ECR_REPO = "941960167356.dkr.ecr.us-east-1.amazonaws.com/eks-webapp"
        BLUE_TAG = "blue"
        GREEN_TAG = "green"
        COLOR_FILE = "active_color.txt"     // file to track current prod color
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

        stage('Verify AWS Identity') {
            steps {
                sh '''
                    echo "=== Current AWS Identity ==="
                    aws sts get-caller-identity
                    echo "=== Should show eks-admin-role, NOT root ==="
                '''
            }
        }

        stage('Test Kubectl Access') {
            steps {
                script {
                    try {
                        sh '''
                            echo "=== Testing kubectl access ==="
                            aws eks update-kubeconfig --name eks-cluster --region $AWS_REGION
                            kubectl get nodes
                            kubectl get namespaces
                            echo "=== Checking EKS cluster authentication mode ==="
                            aws eks describe-cluster --name eks-cluster --region $AWS_REGION --query 'cluster.accessConfig.authenticationMode'
                        '''
                        echo "✅ kubectl access working!"
                    } catch (Exception e) {
                        echo "❌ kubectl access not ready yet: ${e.getMessage()}"
                        echo """
                        🔧 TROUBLESHOOTING STEPS:
                        1. Check if EKS authentication mode update is complete
                        2. Ensure access entry is created for eks-admin-role
                        3. Run these commands manually:
                           aws eks create-access-entry --cluster-name eks-cluster --principal-arn arn:aws:iam::941960167356:role/eks-admin-role --type STANDARD
                           aws eks associate-access-policy --cluster-name eks-cluster --principal-arn arn:aws:iam::941960167356:role/eks-admin-role --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy --access-scope type=cluster
                        """
                        error("EKS authentication not configured yet. Please complete the access entry setup.")
                    }
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
                sh '''
                    echo "=== Logging into ECR using IAM role ==="
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin $ECR_REPO
                '''
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
                    echo """
                    🚀 DEPLOYMENT TO ${INACTIVE_COLOR}
                    -------------------------------------------
                    Applying manifests from k8s/${INACTIVE_COLOR}/
                    Service applied from k8s/service.yaml
                    -------------------------------------------
                    """

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
                    def deployName = (ns == "blue") ? "myservice-blue" : "eks-webapp-green"
                    echo "Checking rollout status of deployment: ${deployName} in namespace: ${namespace}"

                    sh """
                        kubectl rollout status deployment/${deployName} -n ${namespace} --timeout=60s
                    """
                }
            }
        }

        stage('Switch Traffic') {
            steps {
                script {
                    if (env.INACTIVE_COLOR == "blue") {
                        echo "🔁 Switching traffic to BLUE..."
                        sh """
                            kubectl delete ingress eks-webapp-ingress -n green --ignore-not-found
                            kubectl apply -f k8s/ingress.yaml -n blue
                        """
                    } else {
                        echo "🔁 Switching traffic to GREEN..."
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
        success {
            echo "✅ Blue-Green deployment completed successfully!"
        }
    }
}
