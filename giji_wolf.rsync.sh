TARGET=/utage/; rsync --links --recursive --delete --exclude='run' --exclude='.git' --exclude='.svn' $TARGET ec2-user@ec2:$TARGET &
rsync -e "ssh -p 22" --links --recursive --delete --delete-excluded --exclude '.git' --exclude '.svn' /www/giji_wolf/ ec2-user@ec2:/www/giji_wolf/shared/deploy/
