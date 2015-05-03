FILE_TO=/home/7korobi/public_html
rsync --links --recursive --exclude='.git' --exclude='.svn' ~/Dropbox/web_work/images/ /www/giji_assets/public/images/
TARGET=/www/giji_assets/public/
rsync -e "ssh -p 22" --links --recursive --exclude='.git' --exclude='.svn' --exclude='stories' $TARGET 7korobi@s11.rs2.gehirn.jp:$FILE_TO &
