# 🗄️ STACK 20: DATABASE OPERATIONS
## MySQL/MariaDB & PostgreSQL Scripting

---

## 🔰 Why Script Database Operations?

- Automate backups
- Manage users and permissions
- Monitor database health
- Deploy schema changes
- Run migrations

---

## ⚙️ MySQL/MariaDB Basics

### Installation & Setup
```bash
# Install
sudo apt install mysql-server mariadb-server

# Start service
sudo systemctl start mysql
sudo systemctl enable mysql

# Secure installation
sudo mysql_secure_installation

# Connect to MySQL
mysql -u root -p                    # Interactive
mysql -u root -p -e "QUERY"         # Single query
mysql -u root -p database_name      # Connect to specific DB
```

### Basic Commands
```bash
# List databases
mysql -u root -p -e "SHOW DATABASES;"

# List tables
mysql -u root -p -e "USE dbname; SHOW TABLES;"

# Run query
mysql -u root -p -e "SELECT * FROM users LIMIT 10;"

# Execute SQL file
mysql -u root -p database < script.sql

# Export to file
mysql -u root -p -e "SELECT * FROM users" > output.tsv
```

### Import/Export
```bash
# Export entire database
mysqldump -u root -p database_name > backup.sql

# Export with drop table statements
mysqldump -u root -p --add-drop-table database_name > backup.sql

# Export only structure (no data)
mysqldump -u root -p --no-data database_name > structure.sql

# Export only data (no structure)
mysqldump -u root -p --no-create-info database_name > data.sql

# Export specific tables
mysqldump -u root -p database_name table1 table2 > tables.sql

# Import database
mysql -u root -p database_name < backup.sql

# Import with gzip
gunzip < backup.sql.gz | mysql -u root -p database_name

# Combined backup and compress
mysqldump -u root -p database_name | gzip > backup.sql.gz
```

---

## 🛡️ Secure Backup Script

### Basic Backup Script
```bash
#!/bin/bash
# mysql_backup.sh - Automated MySQL backup

set -euo pipefail

DB_NAME="mydb"
DB_USER="backup"
DB_PASS="secret"
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

log() { echo "[$(date)] $*"; }
error() { echo "[ERROR] $*" >&2; exit 1; }

# Create backup directory
mkdir -p "$BACKUP_DIR" || error "Cannot create backup dir"

BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql.gz"

log "Starting backup of $DB_NAME..."

# Perform backup with compression
mysqldump -u "$DB_USER" "-p${DB_PASS}" "$DB_NAME" | \
    gzip > "$BACKUP_FILE"

# Check if backup was created
if [ -f "$BACKUP_FILE" ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    log "Backup created: $BACKUP_FILE ($SIZE)"
else
    error "Backup failed!"
fi

# Clean old backups
find "$BACKUP_DIR" -name "${DB_NAME}_*.sql.gz" -mtime +$RETENTION_DAYS -delete
log "Old backups cleaned up"

# Verify backup integrity
if gunzip -t "$BACKUP_FILE" 2>/dev/null; then
    log "Backup verified successfully"
else
    error "Backup file is corrupted!"
fi
```

### Backup with Lock Tables Minimized
```bash
#!/bin/bash
# mysql_backup_innodb.sh - For InnoDB tables (minimal locking)

mysqldump -u root -p \
    --single-transaction \
    --quick \
    --lock-tables=false \
    --routines \
    --triggers \
    --events \
    mydb | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Backup with Master-Slave Setup
```bash
#!/bin/bash
# mysql_backup_slave.sh - Backup from replica

set -euo pipefail

SLAVE_HOST="replica.example.com"
DB_USER="backup"
DB_PASS="secret"
DB_NAME="production"

# Get replication position
REPL_STATUS=$(mysql -h "$SLAVE_HOST" -u "$DB_USER" -p"$DB_PASS" -e \
    "SHOW SLAVE STATUS\G")

# Extract positions
MASTER_LOG_FILE=$(echo "$REPL_STATUS" | grep "Master_Log_File:" | awk '{print $2}')
READ_MASTER_LOG_POS=$(echo "$REPL_STATUS" | grep "Read_Master_Log_Pos:" | awk '{print $2}')

echo "Master Log: $MASTER_LOG_FILE, Position: $READ_MASTER_LOG_POS"

# Backup from slave
mysqldump -h "$SLAVE_HOST" -u "$DB_USER" -p"$DB_PASS" \
    --single-transaction \
    "$DB_NAME" | gzip > backup_$(date +%Y%m%d).sql.gz
```

---

## 👥 User Management Scripts

### Create Database User
```bash
#!/bin/bash
# create_db_user.sh

set -euo pipefail

NEW_USER="$1"
NEW_PASS="$2"
DB_NAME="$3"

if [ $# -lt 3 ]; then
    echo "Usage: $0 <username> <password> <database>"
    exit 1
fi

mysql -u root << EOF
CREATE USER IF NOT EXISTS '$NEW_USER'@'localhost' IDENTIFIED BY '$NEW_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$NEW_USER'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON \`${DB_NAME}_logs\`.* TO '$NEW_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "User '$NEW_user' created with access to '$DB_NAME'"
```

### Reset User Password
```bash
#!/bin/bash
# reset_db_password.sh

set -euo pipefail

USER="$1"
NEW_PASS="$2"

mysql -u root << EOF
ALTER USER '$USER'@'localhost' IDENTIFIED BY '$NEW_PASS';
FLUSH PRIVILEGES;
EOF

echo "Password reset for user '$USER'"
```

### List All Users and Permissions
```bash
#!/bin/bash
# list_users.sh

mysql -u root -e \
    "SELECT User, Host FROM mysql.user;" 

echo "--- Grants ---"
mysql -u root -e \
    "SHOW GRANTS FOR 'root'@'localhost';"
```

---

## 📊 Database Health Check

### Health Check Script
```bash
#!/bin/bash
# mysql_health_check.sh

set -euo pipefail

DB_USER="root"
DB_PASS="secret"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# Check if MySQL is running
if ! pgrep mysqld > /dev/null; then
    log "ERROR: MySQL is not running!"
    exit 1
fi

# Connection test
if ! mysql -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" > /dev/null 2>&1; then
    log "ERROR: Cannot connect to MySQL!"
    exit 1
fi

log "MySQL is running and accessible"

# Check database size
mysql -u "$DB_USER" -p"$DB_PASS" -e "
    SELECT 
        table_schema AS 'Database',
        ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
    FROM information_schema.tables
    GROUP BY table_schema
    ORDER BY SUM(data_length + index_length) DESC;
"

# Check number of connections
CONNECTIONS=$(mysql -u "$DB_USER" -p"$DB_PASS" -se "SELECT COUNT(*) FROM information_schema.processlist")
log "Current connections: $CONNECTIONS"

# Check slow queries
SLOW_QUERIES=$(mysql -u "$DB_USER" -p"$DB_PASS" -se "SHOW GLOBAL STATUS LIKE 'Slow_queries';" | awk '{print $2}')
log "Slow queries: $SLOW_QUERIES"

# Table check
TABLES=$(mysql -u "$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES;" | wc -l)
log "Total databases: $TABLES"

log "Health check complete!"
```

### Monitor Query Performance
```bash
#!/bin/bash
# mysql_slow_queries.sh

mysql -u root -e "
    SELECT 
        q.user,
        q.db,
        q.command,
        q.time,
        q.state,
        LEFT(q.info, 50) AS query
    FROM information_schema.processlist q
    WHERE q.command != 'Sleep'
    ORDER BY q.time DESC
    LIMIT 10;
"
```

---

## 🔄 PostgreSQL Operations

### Basic PostgreSQL Commands
```bash
# Install
sudo apt install postgresql postgresql-contrib

# Start
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Connect
psql -U postgres                    # As postgres user
psql -d database_name                # Connect to database
psql -U user -d database -h localhost

# Execute query
psql -U postgres -c "SELECT version();"
psql -d mydb -f script.sql           # Execute file

# Export/Import
pg_dump -U postgres mydb > backup.sql
psql -U postgres mydb < backup.sql
pg_dump -U postgres mydb | gzip > backup.sql.gz
```

### PostgreSQL Backup Script
```bash
#!/bin/bash
# postgresql_backup.sh

set -euo pipefail

DB_NAME="mydb"
DB_USER="postgres"
BACKUP_DIR="/backups/postgres"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql.gz"

pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_FILE"

# Clean old backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup created: $BACKUP_FILE"
```

### PostgreSQL User Management
```bash
#!/bin/bash
# create_pg_user.sh

NEW_USER="$1"
NEW_PASS="$2"
DB_NAME="$3"

sudo -u postgres psql << EOF
CREATE USER $NEW_USER WITH PASSWORD '$NEW_PASS';
CREATE DATABASE $DB_NAME OWNER $NEW_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $NEW_USER;
EOF

echo "User $NEW_USER created with database $DB_NAME"
```

---

## 🔧 Common Database Scripts

### Run SQL Migration
```bash
#!/bin/bash
# run_migration.sh

set -euo pipefail

DB_NAME="application"
DB_USER="app_user"
DB_PASS="secret"
MIGRATION_FILE="$1"

if [ -z "$MIGRATION_FILE" ]; then
    echo "Usage: $0 <migration.sql>"
    exit 1
fi

echo "Running migration: $MIGRATION_FILE"
mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$MIGRATION_FILE"
echo "Migration complete!"
```

### Copy Database
```bash
#!/bin/bash
# copy_database.sh

set -euo pipefail

SOURCE_DB="$1"
TARGET_DB="$2"
DB_USER="root"
DB_PASS="secret"

# Create target database
mysql -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS $TARGET_DB"

# Copy data
mysqldump -u "$DB_USER" -p"$DB_PASS" "$SOURCE_DB" | \
    mysql -u "$DB_USER" -p"$DB_PASS" "$TARGET_DB"

echo "Database '$SOURCE_DB' copied to '$TARGET_DB'"
```

### Analyze Tables
```bash
#!/bin/bash
# analyze_tables.sh

DB_NAME="mydb"
DB_USER="root"
DB_PASS="secret"

TABLES=$(mysql -u "$DB_USER" -p"$DB_PASS" -N -e \
    "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA='$DB_NAME'")

for TABLE in $TABLES; do
    echo "Analyzing $TABLE..."
    mysql -u "$DB_USER" -p"$DB_PASS" -e "ANALYZE TABLE $DB_NAME.$TABLE;"
done
```

---

## ⚠️ Security Best Practices

### DON'T
```bash
# ❌ Never store passwords in scripts
DB_PASS="secret"  # Bad!

# ❌ Never use root in production scripts
mysql -u root -p"secret"  # Bad!

# ❌ Don't expose passwords in process list
ps aux | grep mysql  # Shows password!
```

### DO
```bash
# ✅ Use .my.cnf for credentials
# ~/.my.cnf
# [client]
# user=backup
# password=secret

# Then connect without -p
mysql -u backup mydb

# ✅ Use environment variables
export DB_PASS="secret"
mysql -u backup -p"$DB_PASS" mydb

# ✅ Use option file with restricted permissions
chmod 600 ~/.my.cnf
```

### MySQL Config File
```ini
# ~/.my.cnf
[client]
user = backup
password = secret
host = localhost

[mysqldump]
single-transaction
quick
lock-tables=false
```

---

## 🔍 Troubleshooting

### Common MySQL Issues

#### Can't Connect to MySQL
```bash
# Check if MySQL is running
sudo systemctl status mysql
sudo systemctl status mariadb

# Check listening ports
sudo netstat -tlnp | grep 3306
sudo ss -tlnp | grep 3306

# Check logs
sudo tail -f /var/log/mysql/error.log
```

#### Access Denied
```bash
# Reset root password (if forgotten)
sudo systemctl stop mysql
sudo mysqld_safe --skip-grant-tables &
mysql -u root
# Then run: UPDATE mysql.user SET authentication_string=PASSWORD('newpass') WHERE User='root';
sudo systemctl restart mysql
```

#### Table is Crashed
```bash
# Repair MyISAM table
mysql -u root -e "REPAIR TABLE mydb.mytable;"

# Check all tables
mysqlcheck -u root -a mydb

# Repair all tables
mysqlcheck -u root -r mydb
```

#### Backup Fails
```bash
# Check disk space
df -h

# Check MySQL permissions
mysql -u root -e "SHOW GRANTS FOR 'backup'@'localhost';"

# Increase max_allowed_packet
mysql -u root -e "SET GLOBAL max_allowed_packet=1073741824;"
```

### Common PostgreSQL Issues

#### Can't Connect
```bash
# Check status
sudo systemctl status postgresql

# Check configuration
sudo -u postgres psql -c "SHOW config_file;"

# Check pg_hba.conf for authentication
sudo cat /etc/postgresql/*/main/pg_hba.conf
```

#### Connection Too Many
```bash
# Check connections
psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# Kill idle connections
psql -U postgres -c "
    SELECT pg_terminate_backend(pid) 
    FROM pg_stat_activity 
    WHERE state = 'idle' 
    AND query_start < now() - interval '10 minutes';
"
```

---

## 📝 Exercises

### Exercise 1: Backup Script
Create a backup script that:
1. Backs up all databases
2. Compresses the backup
3. Keeps only last 7 days
4. Logs all operations

### Exercise 2: User Management
Create a script that:
1. Creates a new user
2. Grants appropriate permissions
3. Tests the new user's access

### Exercise 3: Health Check
Create a health check that:
1. Checks if MySQL is running
2. Tests a simple query
3. Reports connection count
4. Reports database sizes

---

## ✅ Stack 20 Complete!

You learned:
- ✅ MySQL/MariaDB basics and commands
- ✅ Secure backup scripts with rotation
- ✅ User management scripts
- ✅ Database health monitoring
- ✅ PostgreSQL operations
- ✅ Security best practices
- ✅ Troubleshooting common issues

### Next: Stack 21 - Web Scraping →

---

*End of Stack 20*
