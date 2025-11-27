WoWonder Social Network Platform - Setup Guide
Overview
This is a complete setup of the WoWonder social networking platform running on Replit with PHP, Node.js, and MariaDB.

Quick Start
Prerequisites
PHP 8.3 (✅ installed)
Node.js 20 (✅ installed)
MariaDB (✅ running as background service)
Running the Application
The application runs automatically with two workflows:

Database Server (./run-mariadb.sh)

Starts MariaDB on socket /tmp/mysql.sock
Runs on port 3306
Auto-imports database schema on first run
Status: Running in background
PHP Server (php -S 0.0.0.0:5000 -t .)

Main WoWonder application
Runs on port 5000
Accessible via webview
Status: Running in background
First Access
When you first access the application:

Navigate to the webview preview
The app will redirect you to /welcome page
Follow the installation/setup wizard if needed
Configuration Files
config.php
Main application configuration:

$sql_db_host = "localhost";       // Database host
$sql_db_user = "root";            // Database user
$sql_db_pass = "";                // Database password
$sql_db_name = "wowonder";        // Database name

Important: Socket configuration is set in config.php:

ini_set('mysqli.default_socket', '/tmp/mysql.sock');

nodejs/config.json
Real-time server configuration for Socket.IO:

Site URL (auto-detected from Replit domain)
Database credentials
Purchase code for development
Database Information
Current Setup
Type: MariaDB 10.11.13
Host: localhost (socket: /tmp/mysql.sock)
Port: 3306
Database: wowonder
User: root
Password: (empty)
Database Files
Location: /tmp/mariadb-data/
Schema: Imported from wowonder.sql
Persistence: Session-only (lost on container restart)
Project Structure
.
├── assets/                 # Core PHP libraries
│   ├── init.php           # Main initialization
│   ├── includes/          # PHP includes
│   └── libraries/         # Third-party libraries
├── sources/               # Feature implementations
├── themes/                # Frontend themes
│   ├── wowonder/         # Main theme
│   └── sunshine/         # Alternative theme
├── admin-panel/          # Admin interface
├── api/                  # API endpoints
├── nodejs/               # Real-time server
│   ├── main.js          # Socket.IO server entry
│   ├── config.json      # Configuration
│   └── package.json     # Dependencies
├── install/              # Installation scripts
├── config.php            # Main configuration
├── index.php             # Application entry point
├── run-mariadb.sh        # Database startup script
└── wowonder.sql          # Database schema

Running the Node.js Real-Time Server
For real-time features (chat, notifications, live updates):

cd nodejs
npm start

This runs the Socket.IO server on the configured port. The Node.js server is optional for basic functionality.

Deployment
Current Configuration
Target: VM (Virtual Machine)
Run Command: Starts both MariaDB and PHP server
Port: 5000 (web), 3306 (database)
Deploying to Production
When publishing to production:

Use External Database

Connect to external MySQL (AWS RDS, PlanetScale, etc.)
Update config.php with production credentials
Enable SSL connections
Update Configuration

$sql_db_host = "your-db-host.com";
$sql_db_user = "prod_user";
$sql_db_pass = "secure_password";
$sql_db_name = "wowonder_prod";

Security

Change encryption keys
Enable SSL/TLS
Configure firewall rules
Set up backups
Monitor access logs
Node.js for Production

Use process manager (PM2, systemd)
Configure reverse proxy (nginx, Apache)
Enable clustering for multiple cores
Important: Security Limitations
⚠️ READ SECURITY-WARNING.md before proceeding with production setup.

Development-Only Issues
MariaDB has --skip-grant-tables (no authentication)
System tables not initialized
No privilege management
Database stored in /tmp/ (ephemeral)
Production Requirements
Use managed database service
Enable user authentication
Configure SSL certificates
Set up proper backups
Monitor and audit access
Troubleshooting
Application Won't Start
Check if Database Server workflow is running
Verify MariaDB is listening on /tmp/mysql.sock
Check PHP error logs: php -S 0.0.0.0:5000 -t . (in foreground)
Database Connection Errors
mysqli_sql_exception: No such file or directory

Verify socket path /tmp/mysql.sock exists
Check MariaDB is running: mariadb --socket=/tmp/mysql.sock -e "SHOW DATABASES;"
Restart Database Server workflow
Slow Performance
WoWonder is a large application with complex features
Initial page loads may take 5-10 seconds
This is normal for development environments
Database Import Failed
Schema automatically imports on first run
If it fails, manually import:
mariadb --socket=/tmp/mysql.sock wowonder < wowonder.sql

Node.js Connection Issues
Real-time features optional; app works without them
Start manually: cd nodejs && npm start
Check Socket.IO configured with correct site URL
Environment Variables
The application auto-detects:

Site URL: From REPLIT_DEV_DOMAIN environment variable
Database Socket: Configured in config.php as /tmp/mysql.sock
File Uploads
Upload Directory: /upload/
Supported: Photos, videos, documents
Storage: Local filesystem
Cleanup: Manual (files persist with database data)
Common Tasks
Restart Database
# Kill existing process
pkill -f mariadbd
# Workflows auto-restart

Manually Test Database
mariadb --socket=/tmp/mysql.sock -e "SELECT * FROM wowonder.users LIMIT 5;"

View PHP Error Logs
Errors appear in workflow console logs
Check "Logs" tab in Replit
Clear Browser Cache
Ctrl+Shift+Delete (Windows/Linux)
Cmd+Shift+Delete (Mac)
Then hard refresh: F5 or Ctrl+R
Support & Resources
WoWonder Official: https://www.wowonder.com/
Documentation: Check the app's admin panel
Database Schema: Review wowonder.sql for table structure
Next Steps
✅ Application is running
Access via webview at /welcome
Complete installation wizard if prompted
Create admin account
Configure site settings in admin panel
(Optional) Start Node.js server for real-time features
For production: See SETUP-PRODUCTION.md
Setup Date: November 26, 2025 Platform: Replit Status: Development Environment Ready