#!/bin/bash

source "./env.sh"

# YYYY-MM-DD
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)

function delete_old_backups() {
  echo "Deleting old backup files"

  if [[ -n "${BACKUP_DIR}" && "${BACKUP_DIR}" != '/' ]]; then
    echo "Deleting ${BACKUP_DIR}/*.sql.gz older than ${KEEP_BACKUPS_FOR} days"
    find "${BACKUP_DIR}" -type f -name "*.sql.gz" -mtime +"${KEEP_BACKUPS_FOR}" -exec rm {} \;
  fi
}

function login_to_mysql_command() {
  local mysql_login="-u ${MYSQL_UNAME}"
  [ -n "${MYSQL_PWORD}" ] && mysql_login+=" -p${MYSQL_PWORD}"
  echo "${mysql_login}"
}

function database_list() {
  local show_databases_sql="SHOW DATABASES WHERE \`Database\` NOT REGEXP '${IGNORE_DB}'"
  mysql $(login_to_mysql_command) -e "${show_databases_sql}" | awk -F " " '{if (NR!=1) print $1}'
}

function echo_status() {
  printf '\r%0.s' {0..100}
  printf "\r%s" "$1"
}

function backup_database() {
  local backup_file="${BACKUP_DIR}/${TIMESTAMP}.${database}.sql.gz"
  local output+="\n${database} => ${backup_file}"
  echo_status "Backing up $count of $total databases: $database"
  mysqldump $(login_to_mysql_command) "${database}" | gzip -9 >"${backup_file}"
}

function backup_databases() {
  local databases=$(database_list)
  local total=$(echo "${databases}" | wc -w)
  local output=""
  local count=1

  for database in ${databases}; do
    backup_database
    ((count++))
  done

  echo -e "${output}" | column -t
}

function hr() {
  printf '=%.0s' {1..100}
  printf "\n"
}

function check_backup_dir() {
  [ ! -d "${BACKUP_DIR}" ] && mkdir "${BACKUP_DIR}"
}

function s3_sync() {
  echo_status "Uploading to S3..."
  aws s3 cp "${BACKUP_DIR}" "s3://${S3_BUCKET_URL}/" --recursive --access-key "${S3_ACCESS_KEY}" --secret-key "${S3_SECRET_KEY}"
}

function ftp_sync() {
  lftp -f "
    set ftp:ssl-allow off;
    open ${FTP_HOST};
    user ${FTP_USER} ${FTP_PASS};
    lcd ${BACKUP_DIR};
    mirror --continue --reverse --delete --verbose ${BACKUP_DIR} ${FTP_TARGET_FOLDER};
    bye
  "
}

function upload_to_backup_server() {
  [[ "${UPLOAD_TO_FTP}" == true ]] && ftp_sync
  [[ "${UPLOAD_TO_S3}" == true ]] && s3_sync
}

#==============================================================================
# RUN SCRIPT
#==============================================================================
check_backup_dir
delete_old_backups
hr
backup_databases
hr
upload_to_backup_server
printf "All backed up!\n\n"
