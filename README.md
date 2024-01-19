# daily backup mysql all databases

## sync backup dir to backup FTP server


for use :

```
git clone https://github.com/SamanSh999/backup_mysql.git
```

copy example env and set your database and ftp user password

```
cp env.example.sh env.sh 

vim env.sh 
```

and final

```
./mysql.sh
```

### requirement for Ubuntu/Debian

```
sudo apt install lftp # if you want backup in ftp server
sudo apt install awscli # if you want backup in s3 storage
```

## set crontab to daily backups 

CRON:
- example cron for daily batabase backup at 1:09 am
- min  hr mday month wday command

```
crontab -e
```
and insert end of line

```
09   1  *    *     *    /dir-you-clone-repo/mysql.sh
```

## for restore backup :

```
gunzip < [backupfile.sql.gz] | mysql -u [uname] -p[pass] [dbname]
```