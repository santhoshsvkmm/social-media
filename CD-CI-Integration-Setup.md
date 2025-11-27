CI/CD Integration Guide - Docker + Jenkins
Overview
This guide provides complete integration of Docker containerization with Jenkins CI/CD pipeline for automated testing, building, and deployment of WoWonder.

Architecture
GitHub/GitLab
    ↓ (Push/Tag)
    ↓
Jenkins Pipeline
    ├── Checkout
    ├── Build Docker Image
    ├── Security Scan (Trivy)
    ├── Run Tests
    ├── Push to Registry
    ├── Deploy to Staging
    └── Manual Approval
        └── Deploy to Production

Complete Workflow
1. Developer Workflow
# 1. Clone repository
git clone https://github.com/your-org/wowonder.git
cd wowonder
# 2. Create feature branch
git checkout -b feature/new-feature
# 3. Make changes
# ... edit files ...
# 4. Test locally with Docker
docker-compose up -d
# ... test application ...
docker-compose down
# 5. Commit and push
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
# 6. Create Pull Request
# (Jenkins runs tests on PR)

2. Staging Deployment (Automatic)
# Merge PR to main
git checkout main
git merge feature/new-feature
git push origin main
# Jenkins automatically:
# 1. Builds Docker image
# 2. Runs security scan
# 3. Runs tests
# 4. Pushes to Docker registry
# 5. Deploys to staging environment
# 6. Runs smoke tests

3. Production Deployment (Manual Approval)
# Create release tag
git tag v1.0.0
git push origin v1.0.0
# Jenkins:
# 1. Builds Docker image with version tag
# 2. Runs all tests
# 3. Requests manual approval (in Jenkins UI)
# 4. On approval: deploys to production
# 5. Backs up database
# 6. Updates containers
# 7. Runs smoke tests

Step-by-Step Setup
Phase 1: Docker Setup
1.1 Prepare Docker Environment
# Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# Verify installation
docker --version
docker-compose --version

1.2 Configure Environment
# Copy example environment file
cp .env.example .env
# Edit with your values
nano .env
# Important settings:
MYSQL_ROOT_PASSWORD=change_me_to_secure_password
MYSQL_PASSWORD=change_me_to_secure_password
SITE_URL=http://localhost  # or your domain

1.3 Build and Start Containers
# Build Docker image
docker-compose build
# Start all services
docker-compose up -d
# Check services
docker-compose ps
# View logs
docker-compose logs -f php-app

Phase 2: Jenkins Setup
2.1 Install Jenkins with Docker
# Create Jenkins container
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -u root \
  jenkins/jenkins:lts
# Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

2.2 Configure Jenkins
Access Jenkins: http://localhost:8080
Unlock Jenkins: Paste the initial admin password
Install Suggested Plugins
Create Admin User
2.3 Install Required Plugins
Navigate to: Manage Jenkins → Manage Plugins → Available

Install:

Docker Pipeline
Docker
Pipeline
Git
Credentials Binding
GitHub Integration (if using GitHub)
GitLab Integration (if using GitLab)
2.4 Configure Docker Credentials
Go to: Manage Jenkins → Manage Credentials
Click: Jenkins (global)
Add Credentials:
Kind: Username with password
Username: your_docker_username
Password: your_docker_password
ID: docker-registry-credentials
2.5 Add Git Webhook
For GitHub:

Go to: Repository Settings → Webhooks
Payload URL: http://your-jenkins-url:8080/github-webhook/
Content type: application/json
Events: Push events, Pull requests
Phase 3: Create Jenkins Job
3.1 Create Pipeline Job
Jenkins Dashboard → New Item
Name: wowonder-ci-cd
Type: Pipeline
Click: OK
3.2 Configure Pipeline
Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://github.com/your-org/wowonder.git
Credentials: Add Git credentials if private repo
Branch: */main
Script Path: Jenkinsfile
3.3 Configure Build Triggers
Check: GitHub hook trigger for GIT­SCM polling
Check: Poll SCM (as backup, every 5 minutes)
Phase 4: Configure Registry
4.1 Docker Hub Setup
# Login to Docker Hub
docker login
# Tag image
docker tag wowonder:latest username/wowonder:latest
# Push image
docker push username/wowonder:latest

4.2 Private Registry (optional)
# Run local registry
docker run -d -p 5000:5000 --name registry registry:2
# Tag for local registry
docker tag wowonder:latest localhost:5000/wowonder:latest
# Push to local registry
docker push localhost:5000/wowonder:latest

Automated Tests
Unit Tests
# Run in Jenkinsfile
stage('Unit Tests') {
    steps {
        sh '''
            docker-compose exec -T php-app \
                php -r "
                    require 'vendor/autoload.php';
                    // Run your tests
                "
        '''
    }
}

Integration Tests
stage('Integration Tests') {
    steps {
        sh '''
            docker-compose exec -T php-app curl -f http://localhost/
            docker-compose exec -T php-app curl -f http://localhost/api/
        '''
    }
}

Database Tests
stage('Database Tests') {
    steps {
        sh '''
            docker-compose exec -T mariadb \
                mariadb -u${MYSQL_USER} -p${MYSQL_PASSWORD} \
                -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${MYSQL_DATABASE}';"
        '''
    }
}

Monitoring & Logging
Application Logs
# View application logs
docker-compose logs -f php-app
# View database logs
docker-compose logs -f mariadb
# View Node.js logs
docker-compose logs -f nodejs-server

Jenkins Logs
# View Jenkins container logs
docker logs -f jenkins
# View specific build logs
# Jenkins UI → Job → Build Number → Console Output

Log Aggregation (Optional)
# Add to docker-compose.yml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
# Or use ELK Stack
# - Elasticsearch
# - Logstash
# - Kibana

Security Best Practices
1. Secret Management
# Don't commit .env file
echo ".env" >> .gitignore
# Use Jenkins credentials for secrets
# Jenkins → Credentials → Add Secret
# Or use environment variables
export MYSQL_PASSWORD=$(jenkins get-secret mysql-password)

2. Image Scanning
// In Jenkinsfile
stage('Security Scan') {
    steps {
        sh 'trivy image --severity HIGH,CRITICAL ${DOCKER_IMAGE}'
    }
}

3. Container Security
# Dockerfile best practices
# - Use specific base image version
# - Don't run as root
# - Minimize layers
# - Remove unnecessary packages
FROM php:8.3-apache
USER www-data
# ... rest of Dockerfile

4. Network Security
# docker-compose.yml
networks:
  wowonder-network:
    driver: bridge
    driver_opts:
      com.docker.network.bridge.name: br-wowonder
# Expose only necessary ports
ports:
  - "80:80"
  - "443:443"
  # Don't expose database port publicly

Scaling for Production
1. Load Balancing
version: '3.8'
services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./docker/nginx.conf:/etc/nginx/nginx.conf
  php-app:
    deploy:
      replicas: 3

2. Database Scaling
# Read replicas
# Master-Slave replication
# Or use managed database service

3. Caching Layer
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
  php-app:
    environment:
      CACHE_DRIVER: redis
      REDIS_HOST: redis

Disaster Recovery
1. Backup Strategy
# Automated daily backups
docker-compose exec mariadb \
    mariadb-dump -u root -p${MYSQL_ROOT_PASSWORD} \
    --all-databases > backup-$(date +%Y%m%d).sql
# Or use volume snapshots
docker run --rm -v mariadb_data:/data \
    -v $(pwd)/backups:/backup \
    busybox tar czf /backup/db-backup.tar.gz /data

2. Restore Procedure
# Restore from backup
docker-compose exec -T mariadb \
    mariadb -u root -p${MYSQL_ROOT_PASSWORD} < backup-20240101.sql
# Or restore volume
docker run --rm -v mariadb_data:/data \
    -v $(pwd)/backups:/backup \
    busybox tar xzf /backup/db-backup.tar.gz -C /

3. Failover Testing
# Test container failure recovery
docker stop wowonder-app
# Verify it auto-restarts
# Test database recovery
docker stop wowonder-db
# Verify backup restoration

Troubleshooting
Build Failures
# Check Jenkins logs
docker logs jenkins | tail -50
# Check Docker build
docker build --no-cache .
# Check credentials
docker login

Deployment Failures
# Check container logs
docker-compose logs php-app
docker-compose logs mariadb
# Check network connectivity
docker network ls
docker inspect wowonder-network
# Check volumes
docker volume ls
docker volume inspect mariadb_data

Performance Issues
# Monitor resource usage
docker stats
# Check for bottlenecks
docker-compose logs | grep -i error
docker-compose logs | grep -i timeout
# Optimize docker-compose
# - Increase memory limits
# - Enable caching
# - Use healthchecks

Advanced Topics
1. Multi-Environment Pipeline
// staging vs production deployments
if (env.BRANCH_NAME == 'main') {
    // Deploy to staging
} else if (env.TAG_NAME =~ /v\d+\.\d+\.\d+/) {
    // Deploy to production
}

2. Blue-Green Deployment
# Deploy new version as "green"
docker-compose -f docker-compose.green.yml up -d
# Run tests on green
# If tests pass, switch traffic
# Then remove blue

3. Canary Deployment
# Deploy to small percentage of servers
# Monitor metrics
# Gradually increase traffic

References
Docker: https://docs.docker.com/
Jenkins: https://www.jenkins.io/doc/
Docker Compose: https://docs.docker.com/compose/
Best Practices: https://12factor.net/
Next Steps:

Set up Docker locally and test with docker-compose
Set up Jenkins instance
Configure pipeline job
Test with sample commit/push
Monitor logs and adjust as needed