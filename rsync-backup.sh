#!/bin/bash
BACKUPDIR=/Volumes/友裕\&弥可/Macintosh-HD
BACKUPLOG=/Volumes/友裕\&弥可/backup.log
BACKUPTARGET=" /root /www /private /Users /Library /Applications"

test -e "$BACKUPDIR" || mkdir -p $BACKUPDIR

touch $BACKUPLOG
chmod 777 $BACKUPLOG

# バックアップ実行
echo "`date` backup start" >> $BACKUPLOG
LASTBACKUP=`ls -t $BACKUPDIR | grep -v HEAD | grep -v BACK | grep -v DS_Store | head -1`
NEWBACKUP=`date +%Y-%m-%d`

test "$NEWBACKUP" == "$LASTBACKUP" && exit
test           "" == "$LASTBACKUP" && exit
test -e "$BACKUPDIR/$NEWBACKUP" || mkdir $BACKUPDIR/$NEWBACKUP

sudo rsync -av --delete --link-dest="$BACKUPDIR/$LASTBACKUP" $BACKUPTARGET "$BACKUPDIR/$NEWBACKUP" >> $BACKUPLOG 2>&1
echo "`date` backup end" >> $BACKUPLOG

code=$?
if [ $code -ne 0 ]; then
    cat $BACKUPLOG | mail -s "BACKUP NG CODE IS $code" root
    mv $BACKUPDIR/$NEWBACKUP err-$code-$BACKUPDIR/$NEWBACKUP
    exit 1
fi
echo "`date` backup end" >> $BACKUPLOG


