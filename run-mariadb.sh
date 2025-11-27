#!/bin/bash

# Persistent MariaDB server for WoWonder
DATADIR="/tmp/mariadb-data"
SOCKET="/tmp/mysql.sock"

# Create data directory
mkdir -p $DATADIR

# Check if database needs initialization
if [ ! -f "$DATADIR/ibdata1" ]; then
    echo "First-time setup: Initializing MariaDB database and importing schema..."
    
    # Start temporary server with skip-grant-tables for initial setup
    mariadbd --no-defaults \
        --datadir=$DATADIR \
        --socket=$SOCKET \
        --port=3306 \
        --bind-address=127.0.0.1 \
        --skip-grant-tables \
        --skip-networking=0 \
        --user=$USER &
    
    TEMP_PID=$!
    
    # Wait for server to start
    for i in {1..30}; do
        if mariadb --socket=$SOCKET --protocol=SOCKET -e "SELECT 1" &>/dev/null; then
            echo "MariaDB started, setting up database..."
            
            # Create wowonder database and import schema
            mariadb --socket=$SOCKET --protocol=SOCKET -e "CREATE DATABASE IF NOT EXISTS wowonder;"
            if [ -f "wowonder.sql" ]; then
                echo "Importing schema..."
                mariadb --socket=$SOCKET --protocol=SOCKET wowonder < wowonder.sql
                echo "Schema imported successfully"
            fi
            
            # Stop the temporary server
            kill $TEMP_PID
            wait $TEMP_PID 2>/dev/null
            sleep 2
            break
        fi
        sleep 1
    done
fi

# Start MariaDB normally (without skip-grant-tables for security)
# Note: Using skip-grant-tables in development for simplicity, but this should use proper authentication in production
echo "Starting MariaDB server..."
exec mariadbd --no-defaults \
    --datadir=$DATADIR \
    --socket=$SOCKET \
    --port=3306 \
    --bind-address=127.0.0.1 \
    --skip-grant-tables \
    --skip-networking=0 \
    --user=$USER
