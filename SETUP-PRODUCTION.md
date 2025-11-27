WoWonder Production Deployment Guide
⚠️ CRITICAL SECURITY WARNING
The development setup uses an insecure database configuration.

Before deploying to production, you MUST:

Read SECURITY-WARNING.md
Use an external managed database service
Configure proper authentication
Enable SSL/TLS encryption
Set up monitoring and backups
Production Database Setup
Step 1: Choose a Managed Database Service
Recommended Options:

AWS RDS
- MySQL 8.0+ or MariaDB 10.6+
- Multi-AZ for high availability
- Automated backups
- Read replicas for scaling

PlanetScale
- MySQL-compatible
- Serverless scaling
- Branching for development
- Free tier available

Railway
- Simple deployment
- Automatic backups
- Pay-as-you-go pricing

DigitalOcean Managed Databases
- Managed MySQL/PostgreSQL
- Firewalled by default
- Automatic backups included

Step 2: Create Database and User
Example (using any managed service):

-- Create database
CREATE DATABASE wowonder_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- Create user with limited privileges
CREATE USER 'wowonder_user'@'%' IDENTIFIED BY 'strong_password_here';
-- Grant permissions
GRANT ALL PRIVILEGES ON wowonder_prod.* TO 'wowonder_user'@'%';
FLUSH PRIVILEGES;
-- Import schema
USE wowonder_prod;
SOURCE wowonder.sql;

Step 3: Update Application Configuration
Update config.php:

<?php
// Production Database Configuration
$sql_db_host = "your-db-instance.region.rds.amazonaws.com";  // External DB host
$sql_db_user = "wowonder_user";                                // Dedicated user
$sql_db_pass = "strong_password_here";                         // Strong password
$sql_db_name = "wowonder_prod";                                // Production database
// Remove socket configuration for external database
// ini_set('mysqli.default_socket', ...);  // NOT needed for external DB
$site_url = "https://your-domain.com";  // Your domain
$purchase_code = "your_purchase_code";
// Security settings
$site_key = bin2hex(random_bytes(32));  // Generate new key

Update nodejs/config.json:

{
    "sql_db_host": "your-db-instance.region.rds.amazonaws.com",
    "sql_db_user": "wowonder_user",
    "sql_db_pass": "strong_password_here",
    "sql_db_name": "wowonder_prod",
    "site_url": "https://your-domain.com",
    "purchase_code": "your_purchase_code"
}

Production Deployment Steps
Step 1: Remove Local Database Workflow
Disable the Database Server workflow since we're using external database:

# In Replit, remove or disable the Database Server workflow
# Update .replit if needed (remove database run config)

Step 2: Update Application Run Configuration
Update deployment to only run PHP server:

# Old (development):
./run-mariadb.sh & sleep 3 && php -S 0.0.0.0:5000 -t .
# New (production):
php -S 0.0.0.0:5000 -t .
# Or use production web server (Apache/nginx)

Step 3: Configure SSL/TLS
Use Replit's built-in custom domain with SSL
Or: Configure reverse proxy (nginx) for SSL termination
Ensure HTTPS is enforced in config.php:
$auto_redirect = true;  // Force HTTPS redirect

Step 4: Set Up Node.js for Production
For real-time features in production:

# Install PM2 for process management
npm install -g pm2
# Start Node.js server
cd nodejs
pm2 start main.js --name "wowonder-realtime"
# Save PM2 configuration
pm2 save
pm2 startup

Or with systemd:

# /etc/systemd/system/wowonder-nodejs.service
[Unit]
Description=WoWonder Node.js Server
After=network.target
[Service]
Type=simple
User=www-data
WorkingDirectory=/home/app/wowonder/nodejs
ExecStart=/usr/bin/node main.js
Restart=always
RestartSec=10
[Install]
WantedBy=multi-user.target

Step 5: Configure Web Server
Using nginx (recommended)
upstream php {
    server 127.0.0.1:5000;
}
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    root /home/app/wowonder;
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}
server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    root /home/app/wowonder;
    # SSL Configuration
    ssl_certificate /etc/ssl/certs/your-cert.crt;
    ssl_certificate_key /etc/ssl/private/your-key.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    # Gzip compression
    gzip on;
    gzip_types text/plain text/css text/javascript application/json;
    # PHP configuration (if not using Replit's PHP server)
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    # Rewrite rules from .htaccess
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    # Cache static assets
    location ~* \.(jpg|jpeg|gif|png|css|js|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    # Disable access to sensitive files
    location ~ /\. {
        deny all;
    }
    location ~ /config.php {
        deny all;
    }
}

Using Apache
<VirtualHost *:443>
    ServerName your-domain.com
    ServerAlias www.your-domain.com
    DocumentRoot /home/app/wowonder
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/your-cert.crt
    SSLCertificateKeyFile /etc/ssl/private/your-key.key
    # Enable mod_rewrite
    <Directory /home/app/wowonder>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    # Disable directory listing
    <Directory /home/app/wowonder>
        Options -Indexes
    </Directory>
    # Protect sensitive files
    <Files "config.php">
        Order allow,deny
        Deny from all
    </Files>
    # Gzip compression
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
    </IfModule>
</VirtualHost>
# HTTP redirect to HTTPS
<VirtualHost *:80>
    ServerName your-domain.com
    ServerAlias www.your-domain.com
    Redirect permanent / https://your-domain.com/
</VirtualHost>

Security Checklist
 Database password is strong (16+ characters, mixed case, numbers, symbols)
 SSL/TLS certificate installed and valid
 Database credentials NOT in version control
 config.php not accessible via web
 Database user has minimal required privileges
 Automated backups configured
 Database firewall restricts access to app servers only
 Regular security updates applied
 Admin panel password changed from default
 Site key regenerated (in config.php)
 File upload directory has restricted permissions
 Error reporting disabled in production
 Access logs monitored
 Database transactions logged
Backup & Recovery
Automated Backups
# AWS RDS automatic backups (configured in console)
# - Retention: 30 days
# - Backup window: Off-peak hours
# Manual backup
mysqldump -h your-db-host -u wowonder_user -p wowonder_prod > backup-$(date +%Y%m%d).sql

Recovery Procedure
# Restore from backup
mysql -h your-db-host -u wowonder_user -p wowonder_prod < backup-20240101.sql

Monitoring & Maintenance
Performance Monitoring
-- Check query performance
SHOW PROCESSLIST;
-- Check database size
SELECT table_schema AS "Database", 
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)"
FROM information_schema.tables
GROUP BY table_schema;
-- Index status
SHOW INDEX FROM users;

Regular Maintenance
-- Optimize tables
OPTIMIZE TABLE users, posts, comments;
-- Check table integrity
CHECK TABLE users, posts;
-- Update statistics
ANALYZE TABLE users, posts;

Scaling Considerations
Database Read Replicas: For read-heavy workloads
Caching Layer: Redis/Memcached for session storage
CDN: CloudFlare or AWS CloudFront for static assets
Load Balancing: Multiple application servers
Horizontal Scaling: Database sharding strategy
Monitoring Tools
DataDog: Application performance monitoring
New Relic: Full-stack monitoring
Sentry: Error tracking and reporting
Prometheus + Grafana: Infrastructure monitoring
Troubleshooting Production Issues
Database Connection Timeout
Check firewall rules allow your server IP
Verify database credentials
Check database server status
High Database Usage
Optimize slow queries (use EXPLAIN)
Add appropriate indexes
Archive old data
Implement caching
SSL Certificate Issues
Verify certificate validity date
Check certificate matches domain
Renew certificates before expiration
Use Let's Encrypt for free certificates
Remember: Security is an ongoing process. Regularly update software, monitor logs, and review access patterns.