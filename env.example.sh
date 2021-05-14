#!/bin/bash

#==============================================================================
# FTP Sync Setting
#==============================================================================

FTP_HOST='1.2.3.4'
FTP_USER='user@site.com'
FTP_PASS='password'

FTP_TARGET_FOLDER='/backups'

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