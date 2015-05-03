TARGET=/utage/; rsync -e "ssh -p 2450" --links --recursive --delete --exclude='run' --exclude='.git' --exclude='.svn' $TARGET 7korobi@utage.family.jp:$TARGET &
rsync -e "ssh -p 2450" --links --recursive --delete --delete-excluded --exclude '.git' --exclude '.svn' /www/giji_rails/ 7korobi@utage.family.jp:/www/giji_rails/shared/deploy/
