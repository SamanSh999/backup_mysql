#!/bin/bash

#==============================================================================
# FTP Setting
#==============================================================================

FTP_HOST='1.2.3.4'
FTP_USER='user@site.com'
FTP_PASS='password'

FTP_TARGET_FOLDER='/backups'


#==============================================================================
# S3 Setting
#==============================================================================

S3_ENABLED=true
S3_BUCKET_URL="your-s3-bucket-url"
S3_ACCESS_KEY="your-s3-access-key"
S3_SECRET_KEY="your-s3-secret-key"

UPLOAD_TO_S3=true

#==============================================================================
# Mysql Setting
#==============================================================================

# MYSQL Parameters
MYSQL_UNAME=root
MYSQL_PWORD='password'

# Don't backup databases with these names 
# Example: starts with mysql (^mysql) or ends with _schema (_schema$)
IGNORE_DB="(^mysql|_schema$)"

#==============================================================================
# Other Setting
#==============================================================================

# directory to put the backup files
BACKUP_DIR=$HOME/backups

# include mysql and mysqldump binaries for cron bash user
PATH=$PATH:/usr/local/mysql/bin

# Number of days to keep backups
KEEP_BACKUPS_FOR=30 #days