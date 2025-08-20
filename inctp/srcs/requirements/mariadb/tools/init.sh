#!/bin/sh

# ▶️ Initializing MariaDB
# Print message indicating the start of MariaDB initialization
echo "▶️ Initializing MariaDB..."

# Check: if MariaDB is not yet installed
# We verify by checking if the main MariaDB data directory exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # 📦 Installing MariaDB
    # Print message indicating MariaDB installation
    echo "📦 Installing MariaDB..."
    
    # Create necessary directories for MariaDB data and runtime files
    mkdir -p /var/lib/mysql /run/mysqld
    
    # Set ownership of MariaDB directories to mysql user
    chown -R mysql:mysql /var/lib/mysql /run/mysqld

    # Configure network access
    # Uncomment networking line to allow network connections
    sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
    # Bind MariaDB to all IP addresses
    sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

    # Initialize the MariaDB system tables
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db
else
    # ✅ MariaDB already installed
    # Print message if MariaDB is already present
    echo "✅ MariaDB is already installed"
fi

# Check: if the database does not exist
# We verify by checking if the specific database directory exists
if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then
    # ⚙️ Creating database and user
    # Print message indicating creation of database and user
    echo "⚙️ Creating database and user..."

    # Create SQL script to set up database and user
    cat << EOF > /tmp/setup.sql
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # Bootstrap MariaDB with the setup SQL script
    mariadbd --user=mysql --bootstrap --verbose=0 < /tmp/setup.sql
    
    # Remove temporary SQL file after execution
    rm -f /tmp/setup.sql

    # ✅ Database created
    # Print confirmation message
    echo "✅ Database '${DB_NAME}' has been created."
else
    # ℹ️ Database already exists
    # Print info message if database already exists
    echo "ℹ️ Database '${DB_NAME}' already exists."
fi

# Start MariaDB as the main process
# `exec "$@"` replaces the shell with the command passed as arguments
exec "$@"
