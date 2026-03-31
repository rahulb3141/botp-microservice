pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        ECR_REPO = "941960167356.dkr.ecr.us-east-1.amazonaws.com/eks-webapp"
        BLUE_TAG = "blue"
        GREEN_TAG = "green"
        COLOR_FILE = "active_color.txt"
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
                    if (fileExists(COLOR_FILE)) {
                        ACTIVE_COLOR = readFile(COLOR_FILE).trim()
                    } else {
                        ACTIVE_COLOR = "blue"
                        writeFile file: COLOR_FILE, text: ACTIVE_COLOR
                    }

                    INACTIVE_COLOR = (ACTIVE_COLOR == "blue") ? "green" : "blue"

                    echo "✅ Current Active Environment: ${ACTIVE_COLOR}"
                    echo "🚀 Deploying to Inactive Environment: ${INACTIVE_COLOR}"

                    env.ACTIVE_COLOR = ACTIVE_COLOR
                    env.INACTIVE_COLOR = INACTIVE_COLOR
                }
            }
        }

        stage('Build Docker Image (Simulated)') {
            steps {
                script {
                    def imageTag = (env.INACTIVE_COLOR == "blue") ? BLUE_TAG : GREEN_TAG
                    echo "🛠️ Simulating Docker build for image: ${ECR_REPO}:${imageTag}"
                }
            }
        }

        stage('Login to ECR (Simulated)') {
            steps {
                echo "🔐 Simulating ECR login..."
            }
        }

        stage('Push Docker Image (Simulated)') {
            steps {
                script {
                    def imageTag = (env.INACTIVE_COLOR == "blue") ? BLUE_TAG : GREEN_TAG
                    echo "📤 Simulating docker push: ${ECR_REPO}:${imageTag}"
                }
            }
        }

        stage('Deploy to Inactive Color (Simulated)') {
            steps {
                script {
                    echo "🚀 Simulating deployment to namespace: ${INACTIVE_COLOR}"
                    echo "📦 Pretending to apply manifests from: k8s/${INACTIVE_COLOR}/"
                    echo "✅ Deployment simulation complete."
                }
            }
        }

        stage('Health Check (Simulated)') {
            steps {
                script {
                    echo "❤️ Simulating health check for ${INACTIVE_COLOR}..."
                    sleep 2
                    echo "✅ Health check passed!"
                }
            }
        }

        stage('Switch Traffic (Simulated)') {
            steps {
                script {
                    echo "🔁 Simulating traffic switch from ${ACTIVE_COLOR} → ${INACTIVE_COLOR}"
                    echo "✅ Traffic now pointing to: ${INACTIVE_COLOR}"
                }
            }
        }

        stage('Mark New Active Color') {
            steps {
                script {
                    writeFile file: COLOR_FILE, text: env.INACTIVE_COLOR
                    echo "🟢 Updated active environment: ${INACTIVE_COLOR}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Blue–Green simulated deployment completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed — check logs!"
        }
    }
}
