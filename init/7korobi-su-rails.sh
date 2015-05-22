cat > /etc/hosts <<EOS
192.168.0.249  mongo.family.jp
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

EOS

cat > /etc/yum.repos.d/mongodb-org-3.0.repo <<EOS
[mongodb-org-3.0]
name=MongoDB Repository
baseurl=http://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/3.0/x86_64/
gpgcheck=0
enabled=1

EOS

rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm

yum install git gcc make libyaml openssl lftp wget rsync gcc-c++ patch sqlite mecab mecab-ipadic mongodb-org-tools
yum install ncurses-devel gdbm-devel readline-devel libyaml-devel openssl-devel libxml2-devel libxslt-devel zlib-devel libffi-devel sqlite-devel

scp -r -P 1510 vm-7korobi@192.168.0.152:/c/system/download/unidic-mecab-2.1.2_bin  /usr/lib64/mecab/dic/unidic

