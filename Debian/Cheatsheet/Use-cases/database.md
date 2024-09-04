# Backup a mysql database
mysqldump –u root –p[password] [database_name] > dumpfilename.sql

# Restore a mysql database from backup
mysqldump –u root –p[password] [databasename] < dumpfilename.sql

# Backup multiple mysql databases
mysqldump –u root –p --databases sampled newdb > /tmp/dbdump.sql

mysqldump -u root -p --all-databases > all-database.sql

# Backup a specific table
mysqldump –c –u username –p databasename tablename > /tmp/databasename.tablename.sql

# Restore all databases
mysql -u root -p < /tmp/alldbs55.sql

# Backup databases in compress format
mysqldump --all-databases | bzip2 -c > databasebackup.sql.bz2 

mysqldump --all-databases | gzip> databasebackup.sql.gz 

# Check status 
mysqladmin -u root -p status
