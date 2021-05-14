#!/bin/bash

source "./env.sh"

# YYYY-MM-DD
# TIMESTAMP=$(date +%F)
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)

function delete_old_backups()
{
	echo saman;
	# 
  if [[ ! -z "${BACKUP_DIR}" && ! $BACKUP_DIR = '/' ]]; then
    echo "Deleting $BACKUP_DIR/*.sql.gz older than $KEEP_BACKUPS_FOR days"
    find $BACKUP_DIR -type f -name "*.sql.gz" -mtime +$KEEP_BACKUPS_FOR -exec rm {} \;
  fi
}

function mysql_login() {
  local mysql_login="-u $MYSQL_UNAME" 
  if [ -n "$MYSQL_PWORD" ]; then
    local mysql_login+=" -p$MYSQL_PWORD" 
  fi
  echo $mysql_login
}

function database_list() {
  local show_databases_sql="SHOW DATABASES WHERE \`Database\` NOT REGEXP '$IGNORE_DB'"
  echo $(mysql $(mysql_login) -e "$show_databases_sql"|awk -F " " '{if (NR!=1) print $1}')
}

function echo_status(){
  printf '\r'; 
  printf ' %0.s' {0..100} 
  printf '\r'; 
  printf "$1"'\r'
}

function backup_database(){
    backup_file="$BACKUP_DIR/$TIMESTAMP.$database.sql.gz" 
    output+="$database => $backup_file\n"
    echo_status "...backing up $count of $total databases: $database"
    $(mysqldump $(mysql_login) $database | gzip -9 > $backup_file)
}

function backup_databases(){
  local databases=$(database_list)
  local total=$(echo $databases | wc -w | xargs)
  local output=""
  local count=1
  for database in $databases; do
    backup_database
    local count=$((count+1))
  done
  echo -ne $output | column -t
}

function hr(){
  printf '=%.0s' {1..100}
  printf "\n"
}


function check_backup_dir(){
  if [ ! -d $BACKUP_DIR ]; then
    mkdir $BACKUP_DIR
  fi
}

function ftp_sync(){
lftp -f "
set ftp:ssl-allow off;
open $FTP_HOST
user $FTP_USER $FTP_PASS
lcd $BACKUP_DIR
mirror --continue --reverse --delete --verbose $BACKUP_DIR $FTP_TARGET_FOLDER
bye
" 
}


#==============================================================================
# RUN SCRIPT
#==============================================================================
check_backup_dir
delete_old_backups
hr
backup_databases
hr
ftp_sync
printf "All backed up!\n\n"