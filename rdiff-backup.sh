#!/bin/bash

BACKUPDIR=/Volumes/友裕\&弥可/rdiff
BACKUPLOG=/Volumes/友裕\&弥可/backup.log

test -e "$BACKUPDIR" || mkdir -p $BACKUPDIR
touch $BACKUPLOG
chmod 777 $BACKUPLOG

echo "`date` backup start" >> $BACKUPLOG
for TARGET in /private/etc /Users /Library /Applications
do
  mkdir -p $BACKUPDIR/$TARGET
  sudo /usr/local/bin/rdiff-backup $TARGET $BACKUPDIR/$TARGET
done
echo "`date` backup end" >> $BACKUPLOG

for TARGET in /private/etc /Users /Library /Applications
do
  sudo /usr/local/bin/rdiff-backup --list-increment-sizes $BACKUPDIR/$TARGET
  echo "---( $TARGET )---"
done

echo "-----------------------------------------------------------------------------"
echo "--- how to restore ---"
echo "  USAGE: rdiff-backup -r TIME backup_dir restore_dir"
