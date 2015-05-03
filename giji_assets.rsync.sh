FILE_TO=/home/7korobi/public_html
TARGET=/www/giji_assets/public/
rsync --links --recursive --exclude='.git' --exclude='.svn' ~/Dropbox/web_work/images/ /www/giji_assets/public/images/
rsync -e "ssh -p 22" --links --recursive --exclude='.git' --exclude='.svn' --exclude='stories' $TARGET 7korobi@s11.rs2.gehirn.jp:$FILE_TO &
lftp -u 7korobi@kanto.me,7ZZwqTLG ftp.gmobb.jp -e "set ftp:ssl-allow off; mirror -X .htaccess --only-newer -R /www/giji_assets/public/ /;" &
