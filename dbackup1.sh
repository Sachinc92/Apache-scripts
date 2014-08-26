#!/bin/bash

# -------------- Backup Automation Script ------------------
#  Author         : Sachin
#  Email          : sachinsacc@live.in
#  Created on     : Aug 25, 2014
# ----------------------------------------------------------

# Create a user for backup with SELECT,EVENT,RELOAD,SHOW TABLES,LOCK TABLES privileges instead of root user #


TIMESTAMP=$(date +"%A")
BASE_DIR="/path/to/DBackup"
BACKUP_DIR="$BASE_DIR/DAILY/$TIMESTAMP"
BAKING_DIR="$BASE_DIR/DAILY/"
WEEK_DIR="$BASE_DIR/WEEKLY"
MYSQL_USER="bkup_user"
MYSQL_PASSWORD="password"
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump
LOG_FILE=$BASE_DIR/backup.log
LOG_TIME=$(date +"%d-%m-%Y_%H.%M.%S")
DOW=$(date +"%u")
WOY=$(date +"%V")
TAR="/bin/tar"


# Creating backup directory

                if [ ! -d "$BACKUP_DIR" ]
                then
                mkdir -p $BACKUP_DIR
                fi

                if [ ! -d "$BACKUP_DIR" ];
                then
                echo "Invalid directory: $BACKUP_DIR"
                exit 1
                fi

  
# Writing Log file.
exec >> $LOG_FILE

echo "------- Backup Started At $LOG_TIME ------------"

#Checking existing backup

                if [ -f "$BAK_FILE" ];
                then
                echo "Overwriting $BAK_FILE"
                fi

# Dumping Database
$MYSQLDUMP --user $MYSQL_USER -p$MYSQL_PASSWORD --events --all-databases > $BACKUP_DIR/Alldb.sql
echo "----> $BACKUP_DIR/alldb.sql saved."
DATABASES=`$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

                for db in $DATABASES; do
                $MYSQLDUMP --force --opt --events --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUP_DIR/$db.sql.gz"
                echo "--> $BACKUP_DIR/$db.sql.gz saved."
                done


# Weekly backup

                if [ ! -d "$WEEK_DIR" ]
                then
                mkdir -p $WEEK_DIR
                fi

                if [ "$DOW" -eq 7 ]
                then
                $TAR -cvzf  $WEEK_DIR/"week-$WOY.tar.gz" -C $BAKING_DIR .
                fi

END=$(date +"%d-%m-%Y_%H.%M.%S")

echo -e "------- Backup Completed At $END ----------\n"
