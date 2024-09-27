# mysqldump (for backups):
```
mysqldump -u username -p database_name > backup.sql
mysqldump -u username -p --all-databases > full_backup.sql
```

# mysql (to connect to MySQL):
```
mysql -u username -p
mysql -h hostname -u username -p database_name
```

# mysqlimport (to import data):
```
mysqlimport -u username -p database_name data.txt
```

# mysqladmin (for administrative tasks):
```
mysqladmin -u root -p status
mysqladmin -u root -p processlist
mysqladmin -u root -p create new_database
mysqladmin -u root -p drop old_database
```

# mysqlcheck (for table maintenance):
```
mysqlcheck -u username -p database_name
mysqlcheck -u username -p --all-databases --optimize
```

# mysqlshow (to display database information):
```
mysqlshow -u username -p
mysqlshow -u username -p database_name
```

# mysqldumpslow (to analyze slow query logs):
```
mysqldumpslow /var/log/mysql/mysql-slow.log
```

# mysqlbinlog (to display binary log contents):
```
mysqlbinlog /var/log/mysql/mysql-bin.000001
```

# Shell scripts for automated backups:
```bash
#!/bin/bash
DATE=$(date +%Y-%m-%d)
mysqldump -u username -p'password' database_name > backup_$DATE.sql
```

# Monitoring scripts:
```bash
#!/bin/bash
mysql -u username -p'password' -e "SHOW PROCESSLIST" | grep -v root
```

# Replication setup:
```
CHANGE MASTER TO MASTER_HOST='master_host', MASTER_USER='replication_user', MASTER_PASSWORD='password', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=123;
START SLAVE;
```

# Performing a secure MySQL installation:
```
mysql_secure_installation
```