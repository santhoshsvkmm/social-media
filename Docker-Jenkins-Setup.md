WoWonder Docker & Jenkins Complete Setup Index
📦 Files Created
Docker Configuration Files
File	Purpose
Dockerfile	Main PHP application container with Apache
docker-compose.yml	Development environment (MariaDB + PHP + optional Node.js)
docker/docker-compose.prod.yml	Production environment with enhanced logging & security
docker/Dockerfile.nodejs	Optional Node.js real-time server container
docker/entrypoint.sh	Container initialization script (auto-configures app)
docker/apache-config.conf	Apache VirtualHost configuration with rewrite rules
docker/php.ini	PHP configuration optimized for WoWonder
.dockerignore	Files to exclude from Docker build
.env.example	Environment variables template
Jenkins CI/CD Pipeline
File	Purpose
Jenkinsfile	Complete CI/CD pipeline with 8 stages
Documentation
File	Purpose
DOCKER-SETUP.md	Step-by-step Docker & Jenkins setup guide
CI-CD-INTEGRATION.md	Complete workflow and integration guide
DOCKER-JENKINS-INDEX.md	This file - master index
🚀 Quick Start
Option 1: Docker Development (Fastest)
# 1. Copy environment file
cp .env.example .env
# 2. Start all services
docker-compose up -d
# 3. Access application
open http://localhost
# 4. View logs
docker-compose logs -f php-app

Option 2: Production Deployment
# 1. Configure .env with production settings
cp .env.example .env
nano .env
# 2. Start production stack
docker-compose -f docker-compose.prod.yml up -d
# 3. Verify health
docker-compose ps

Option 3: With Jenkins CI/CD
# 1. Start Jenkins
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
# 2. Follow setup guide → DOCKER-SETUP.md
# 3. Create pipeline job
# 4. Push code to trigger automation

📋 Pipeline Stages
1. CHECKOUT      → Git checkout (triggered by push/tag)
2. BUILD         → Build Docker image
3. SECURITY SCAN → Trivy vulnerability scan
4. TEST          → Run integration tests
5. PUSH          → Push to Docker registry (main branch)
6. DEPLOY STAGING → Deploy to staging (main branch)
7. SMOKE TESTS   → Verify deployment
8. DEPLOY PROD   → Manual approval for production (tags only)

🔧 Service Topology
┌─────────────────────────────────────────┐
│        Docker Compose Network           │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │   PHP-APP    │  │  MARIADB     │   │
│  │   (Port 80)  │  │ (Port 3306)  │   │
│  └──────────────┘  └──────────────┘   │
│         │                  │            │
│         └────────┬─────────┘            │
│                  │                      │
│  ┌──────────────────────────────────┐  │
│  │   NODEJS-SERVER (Optional)       │  │
│  │        (Port 3001)               │  │
│  └──────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘

📚 Documentation Guide
For Quick Setup
→ Start with DOCKER-SETUP.md - 5-10 minute setup

For CI/CD Integration
→ Read CI-CD-INTEGRATION.md - Complete workflow + advanced topics

For Reference
→ Use DOCKER-JENKINS-INDEX.md (this file)

⚙️ Environment Variables
Key configuration variables in .env:

# Database
MYSQL_ROOT_PASSWORD=rootpass123
MYSQL_USER=wowonder_user
MYSQL_PASSWORD=userpass123
# PHP
PHP_MEMORY_LIMIT=512M
PHP_MAX_UPLOAD_SIZE=100M
# Site
SITE_URL=http://localhost
PURCHASE_CODE=your_code_here

Full list: See .env.example

🎯 Use Cases
Development
Local testing with docker-compose
Auto-reload on code changes
Full access to logs
Database persistence in development
docker-compose up -d
# Edit code - changes auto-reload

Staging
Test before production
Run full test suite
Automated from main branch
Separate database/data
docker-compose -f docker-compose.prod.yml up -d

Production
Manual approval required
Database backups before deploy
Health checks on all services
Automatic rollback on failure
Tag-based deployments (v*..)
git tag v1.0.0
git push origin v1.0.0
# Jenkins requests approval
# Deploy automatically

🔐 Security Features
✅ Environment variable secrets
✅ No sensitive data in images
✅ Trivy vulnerability scanning
✅ Health checks on all services
✅ Network isolation via docker networks
✅ Non-root container execution
✅ Log rotation configured
✅ Production hardened config
📊 Jenkins Pipeline Features
✅ Automated testing on every push
✅ Docker image building & tagging
✅ Registry push (Docker Hub/Private)
✅ Automated staging deployment
✅ Manual production approval
✅ Smoke tests post-deploy
✅ Security scanning (Trivy)
✅ Build notifications
✅ Disaster recovery options
🛠️ Common Tasks
View Logs
docker-compose logs -f php-app
docker-compose logs -f mariadb
docker-compose logs -f nodejs-server

Enter Container
docker-compose exec php-app bash
docker-compose exec mariadb mariadb -u root -p

Backup Database
docker-compose exec mariadb mysqldump -u root -p wowonder > backup.sql

Restore Database
docker-compose exec -T mariadb mariadb -u root -p wowonder < backup.sql

Rebuild Image
docker-compose build --no-cache

Scale Services
docker-compose up -d --scale php-app=3

🚨 Troubleshooting
Container won't start
docker-compose logs php-app
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d

Port already in use
# Change port in docker-compose.yml
ports:
  - "8080:80"  # Use 8080 instead

Database connection failed
# Wait for MySQL to start
sleep 30
docker-compose exec mariadb mariadb-admin ping

Jenkins not building
# Check Jenkins logs
docker logs jenkins
# Verify webhook configured
# Verify Jenkinsfile exists
# Check branch name matches

📈 Next Steps
Immediate (5 min)

cp .env.example .env
docker-compose up -d
Access http://localhost
Short-term (30 min)

Read DOCKER-SETUP.md
Customize .env for your needs
Test application features
Medium-term (1-2 hours)

Set up Jenkins instance
Configure pipeline job
Test CI/CD workflow
Long-term (ongoing)

Monitor production deployments
Optimize docker-compose config
Add custom tests
Implement monitoring
📞 Support Resources
Docker: https://docs.docker.com/
Jenkins: https://www.jenkins.io/doc/
WoWonder: https://www.wowonder.com/
Docker Compose: https://docs.docker.com/compose/
📝 File Organization
wowonder/
├── Dockerfile                    # Main container
├── docker-compose.yml            # Dev environment
├── Jenkinsfile                   # CI/CD pipeline
├── .env.example                  # Config template
├── .dockerignore                 # Docker build excludes
│
├── docker/
│   ├── Dockerfile.nodejs         # Node.js server
│   ├── docker-compose.prod.yml   # Prod environment
│   ├── entrypoint.sh            # Init script
│   ├── apache-config.conf       # Apache config
│   └── php.ini                  # PHP settings
│
├── DOCKER-SETUP.md              # Setup guide
├── CI-CD-INTEGRATION.md         # Integration guide
├── DOCKER-JENKINS-INDEX.md      # This file
│
├── assets/                       # PHP libraries
├── sources/                      # Features
├── themes/                       # Frontend themes
├── nodejs/                       # Real-time server
├── upload/                       # User uploads
└── wowonder.sql                  # Database schema

✅ Verification Checklist
After setup:

 Docker installed: docker --version
 Docker Compose works: docker-compose --version
 Application running: http://localhost
 Database connected: docker-compose exec mariadb mariadb-admin ping
 Logs accessible: docker-compose logs
 Environment configured: .env file created
 Images building: docker-compose build succeeds
 Jenkins accessible: http://localhost:8080 (if running)
 Pipeline job created: Check Jenkins dashboard
 Git webhook configured: Check repo settings
🎓 Learning Path
Beginner: Follow DOCKER-SETUP.md step-by-step
Intermediate: Use docker-compose for local development
Advanced: Set up Jenkins pipeline
Expert: Customize pipeline, add monitoring, implement blue-green deployments
Created: November 26, 2025 Status: Production Ready Version: 1.0.0

Questions? See DOCKER-SETUP.md or CI-CD-INTEGRATION.md for detailed explanations.s