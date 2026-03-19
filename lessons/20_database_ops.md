# 🗄️ STACK 20: DATABASE OPERATIONS
## MySQL/MariaDB & PostgreSQL Scripting

---

## 🔰 MySQL Basics

```bash
# Connect to MySQL
mysql -u root -p
mysql -h localhost -u user -p database_name

# Execute query
mysql -u root -p -e "SELECT * FROM users"

# Import/Export
mysqldump -u root -p database > backup.sql
mysql -u root -p database < backup.sql
```

---

## 📝 Database Scripts

### Backup Script
```bash
#!/bin/bash
# mysql_backup.sh

set -euo pipefail

DB_NAME="mydb"
DB_USER="backup"
DB_PASS="secret"
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql"

mkdir -p "$BACKUP_DIR"
mysqldump -u "$DB_USER" "-p${DB_PASS}" "$DB_NAME" > "$BACKUP_FILE"

# Compress
gzip "$BACKUP_FILE"

# Keep only 7 days
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete
```

### User Management
```bash
#!/bin/bash
# create_user.sh

set -euo pipefail

DB_USER="newuser"
DB_PASS="password"
DB_NAME="appdb"

mysql -u root << EOF
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
```

### Safety Notes

- Quote shell variables when building commands and paths
- Prefer creating a full backup path in one variable before using it
- Be careful embedding variables inside SQL; validate names if they come from user input

---

## 📊 PostgreSQL

```bash
# Connect
psql -U postgres
psql -d database_name

# Execute query
psql -U postgres -c "SELECT * FROM users"

# Backup
pg_dump -U postgres mydb > backup.sql
pg_dump -U postgres mydb | gzip > backup.sql.gz
```

---

## ✅ Stack 20 Complete!
