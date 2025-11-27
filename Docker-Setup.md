Docker & Jenkins Setup Guide
Docker Installation & Usage
Prerequisites
Docker 20.10+
Docker Compose 2.0+
At least 2GB RAM available
Quick Start with Docker Compose
Clone or navigate to the project directory
cd wowonder

Create environment file
cp .env.example .env
# Edit .env with your configuration

Start all services
docker-compose up -d

Wait for services to be healthy
docker-compose ps
# Wait until all services show "healthy"

Access the application
Application: http://localhost
Database: localhost:3306 (use credentials from .env)
Docker Compose Services
Development Setup (Default)
docker-compose up -d

Services started:

mariadb: Database server on port 3306
php-app: Web application on port 80/443
nodejs-server: Real-time server (profile: realtime)
Enable Real-time Server
docker-compose --profile realtime up -d

Production Setup
docker-compose -f docker-compose.prod.yml up -d

More hardened configuration with:

Logging configured
Health checks on all services
Security settings enforced
Automatic restarts
Docker Compose Commands
# View running services
docker-compose ps
# View logs
docker-compose logs -f php-app
# Enter container shell
docker-compose exec php-app bash
# Stop services
docker-compose stop
# Stop and remove containers/volumes
docker-compose down -v
# Rebuild image
docker-compose build --no-cache
# Scale services
docker-compose up -d --scale nodejs-server=3

Docker Commands
# Build image
docker build -t wowonder:latest .
# Build Node.js image
docker build -f docker/Dockerfile.nodejs -t wowonder-nodejs:latest .
# Tag image for registry
docker tag wowonder:latest docker.io/username/wowonder:latest
# Push to registry
docker push docker.io/username/wowonder:latest
# Run container
docker run -d --name wowonder -p 80:80 wowonder:latest
# View container logs
docker logs -f wowonder
# Execute command in container
docker exec -it wowonder bash
# Stop container
docker stop wowonder
# Remove container
docker rm wowonder

Environment Configuration
Edit .env file:

# Database
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=wowonder
MYSQL_USER=wowonder_user
MYSQL_PASSWORD=secure_user_password
# PHP
PHP_MEMORY_LIMIT=512M
PHP_MAX_UPLOAD_SIZE=100M
# Site
SITE_URL=https://yourdomain.com
PURCHASE_CODE=your_purchase_code
SITE_KEY=change_to_random_secure_key
# Node.js
NODE_ENV=production

Jenkins Pipeline Setup
Prerequisites
Jenkins 2.400+
Docker plugin for Jenkins
Git plugin
Pipeline plugin
Installation Steps
Install Jenkins Plugins
Manage Jenkins → Plugin Manager
Install:
  - Docker Pipeline
  - Docker
  - Pipeline
  - Git
  - Credentials Binding

Configure Docker Credentials
Manage Jenkins → Manage Credentials
Add Credentials:
  - Type: Username with password
  - Username: docker_registry_username
  - Password: docker_registry_password
  - ID: docker-registry-credentials

Create Jenkins Job
New Item → Pipeline
Name: wowonder-ci-cd
Pipeline script from SCM:
  - SCM: Git
  - Repository URL: https://github.com/your-org/wowonder.git
  - Branch: */main
  - Script Path: Jenkinsfile

Configure Build Triggers
Pipeline Syntax:
Triggers → GitHub hook trigger for GIT­SCM polling

Jenkinsfile Stages
1. Checkout
Pulls source code from Git repository
Checks out specified branch/tag
2. Build
Builds Docker image
Tags with version/commit info
Builds Node.js image if enabled
3. Security Scan
Scans image with Trivy
Reports vulnerabilities
Fails on CRITICAL findings (can be modified)
4. Test
Starts services with docker-compose
Tests connectivity to PHP service
Tests database connectivity
Validates API endpoints
5. Push to Registry
Authenticates with Docker Registry
Pushes image to registry
Tags as latest
Runs on main branch only
6. Deploy to Staging
Pulls latest image
Deploys using docker-compose
Runs health checks
Runs on main branch
7. Deploy to Production
Requires manual approval (input step)
Backs up current database
Updates production containers
Runs smoke tests
Only runs on version tags (v*..)
8. Smoke Tests
Tests application endpoints
Validates database connection
Checks API availability
Running the Pipeline
Manual Trigger
Jenkins Dashboard → wowonder-ci-cd → Build Now

Automatic Trigger (Git Push)
# Push to main branch triggers staging deployment
git push origin main
# Create version tag triggers production approval
git tag v1.0.0
git push origin v1.0.0

Build with Parameters
Jenkins Dashboard → wowonder-ci-cd → Build with Parameters
- DOCKER_REGISTRY: docker.io
- DOCKER_REPO: myorg/wowonder
- IMAGE_TAG: 1.0.0
- DEPLOY_ENV: staging/production

Pipeline Customization
Add Slack Notifications
post {
    success {
        slackSend(
            color: 'good',
            message: "Build succeeded: ${env.BUILD_URL}"
        )
    }
    failure {
        slackSend(
            color: 'danger',
            message: "Build failed: ${env.BUILD_URL}"
        )
    }
}

Add Email Notifications
post {
    failure {
        emailext(
            subject: "Build failed",
            body: "See ${env.BUILD_URL}",
            to: "team@example.com"
        )
    }
}

Add SonarQube Analysis
stage('Code Quality') {
    steps {
        withSonarQubeEnv('SonarQube') {
            sh 'sonar-scanner'
        }
    }
}

Monitoring & Logs
View Jenkins logs:

# Live logs during build
Jenkins UI → Job → Console Output
# Docker logs from container
docker logs -f jenkins
# Access Jenkins logs
docker exec jenkins cat /var/log/jenkins/jenkins.log

Jenkins Backup & Recovery
Backup Jenkins data:

docker cp jenkins:/var/jenkins_home ./jenkins-backup
tar -czf jenkins-backup.tar.gz jenkins-backup/

Restore Jenkins data:

tar -xzf jenkins-backup.tar.gz
docker cp jenkins-backup jenkins:/var/jenkins_home
docker restart jenkins

Troubleshooting
Docker Issues
Container won't start:

docker-compose logs mariadb
docker-compose logs php-app
# Rebuild without cache
docker-compose build --no-cache
docker-compose up -d

Database connection refused:

# Check if MySQL is ready
docker-compose exec mariadb mariadb-admin ping
# Wait before starting PHP service
docker-compose up -d mariadb
sleep 30
docker-compose up -d php-app

Port already in use:

# Find process using port
lsof -i :80
lsof -i :3306
# Use different port in docker-compose
ports:
  - "8080:80"  # Use port 8080 instead

Jenkins Issues
Jenkinsfile not found:

Verify script path in job configuration
Ensure Jenkinsfile is in repository root
Check branch name matches
Docker credentials not working:

Verify credentials ID matches Jenkinsfile
Test credentials in Jenkins
Check Docker registry URL format
Pipeline hangs:

Check container logs: docker logs -f <container>
Increase timeout values
Check system resources (disk space, memory)
Production Deployment Checklist
 Configure external database (AWS RDS, etc.)
 Set up SSL/TLS certificates
 Configure email notifications
 Set up monitoring (Prometheus, DataDog, etc.)
 Configure backups and retention policy
 Enable security scanning in pipeline
 Set resource limits in docker-compose
 Configure log rotation
 Test disaster recovery procedures
 Document deployment process
 Set up alerting for failures
 Configure rate limiting
 Enable CORS properly
 Review security headers
References
Docker Documentation
Docker Compose Documentation
Jenkins Documentation
Jenkins Pipeline Documentation