#!/usr/bin/env ruby-local-exec

no = ARGV[0][0..2]
hwaddr = no[1..2]

console = %q|\[\033[1;30m\][\u@\[\033[1;37m\]| + no + %q|\[\033[32m\] \W\[\033[35m\]$(__git_ps1 ' %s')\[\033[1;30m\]]\$\[\033[00m\] |
git_path = Dir.glob("/usr/share/doc/git-*/contrib/completion/git-completion.bash").first

open('/home/7korobi/web-env','w').puts <<-_SH_
echo "no: #{no}  environment set."

PATH=/utage:/home/7korobi/.rbenv/shims:/home/7korobi/.rbenv/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/rvm/bin:/home/7korobi/bin
UTAGE=#{no}
SSH_PORT=#{no}0
WEB_PORT=#{no}9
WSS_PORT=#{no}8
RESQUE_PORT=#{no}7

export LANG=ja_JP.UTF-8
export PATH
export UTAGE
export SSH_PORT
export WEB_PORT
export WSS_PORT
export RESQUE_PORT
export RBENV_VERSION=2.1.2
export MONGO_URL="mongodb://7korobi:kotatsu3@mongo.family.jp/giji"
export REDIS_URL="redis://mongo.family.jp:6379/0"

eval "$(rbenv init -)"

alias dstat-full='~/dstat/dstat -Tclmdrn'
alias dstat-mem='~/dstat/dstat -Tclm'
alias dstat-cpu='~/dstat/dstat -Tclr'
alias dstat-net='~/dstat/dstat -Tclnd'
alias dstat-disk='~/dstat/dstat -Tcldr'

source #{git_path}
source /home/7korobi/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=auto
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=auto

cd (){
  command cd $1
  export PS1="#{console}"
}
cd .

_SH_


open('/home/7korobi/.bash_profile','w').puts <<-_SH_
# .bash_profile
test -f ~/.bashrc  && . ~/.bashrc
test -f ~/web-env  && . ~/web-env
_SH_


commands = <<-_SH_
chmod 755  ~/web-env ~/.bash_profile
_SH_
commands.each_line {|sh| system sh}
