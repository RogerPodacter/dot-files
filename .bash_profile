. "$HOME/.profile"

source "$HOME/.rapgenius-db-backups-creds"
source "$HOME/rails_apps/rapgenius/script/gc_env"

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

complete -o default -W "\$(git branch 2>/dev/null | cut -c 3-)" git gco

export CLICOLOR=1
# export PS1="\w\[\033[31m\] \[\033[00m\]>: "
export PS1="\w\[\033[31m\]\[\033[00m\]\$(parse_git_branch) >: "
export EDITOR="mate -w"

alias edit_profile='mate ~/.bash_profile'
alias edit_irbrc='mate ~/.irbrc'

alias edit_gmail_filters='mate ~/bin/gmail_filters/gmail_filters.rb'
alias compile_gmail_filters='ruby ~/bin/gmail_filters/gmail_filters.rb > ~/gmail_filters.xml'

alias rg='cd ~/rails_apps/rapgenius'

alias g='git '
alias gst='git status'
alias gs='git status'
alias gl='git pull'
alias gp='git push'
alias gd='git diff | mate'
alias gdh='git diff HEAD | mate'
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gb='git branch'
alias gco='git checkout'
alias gap='git add --patch'
alias gdc='git diff --cached | mate'
alias gba='git branch -a'
alias gpom='git push origin master'
alias gphm='git push production master'
alias gppm='git push production master'
alias gg='git grep'

alias c='clear'
alias mv='mv -i'
alias rm='rm -i'
alias md='mkdir'
 
# Need to do this so you use backspace in screen...I have no idea why
alias screen='TERM=screen screen'
 
# listing files
alias l='ls -alh'
alias ltr='ls -ltr'
alias lth='l -t|head'
alias lh='ls -Shl | less'
alias tf='tail -f -n 100'
alias t500='tail -n 500'
alias t1000='tail -n 1000'
alias t2000='tail -n 2000'
 
# editing shortcuts
alias m='mate'
alias v='vim'
alias vi='vim'
 
# grep for a process
function psg {
  FIRST=`echo $1 | sed -e 's/^\(.\).*/\1/'`
  REST=`echo $1 | sed -e 's/^.\(.*\)/\1/'`
  ps aux | grep "[$FIRST]$REST"
}
 
alias h?="history | grep "
 
# display battery info on your Mac
# see http://blog.justingreer.com/post/45839440/a-tale-of-two-batteries
alias battery='ioreg -w0 -l | grep Capacity | cut -d " " -f 17-50'

sc () {
  if [ -f ./script/rails ]; then 
    rails console $argv
  else
    ./script/console $argv
  fi
}

ss () {
  if [ -f ./script/rails ]; then 
    rails server $argv --debugger
  else
    bundle exec ./script/server $argv --debugger
  fi
}

sg () {
  if [ -f ./script/rails ]; then 
    rails generate $argv
  else
    ./script/generate $argv
  fi
}
 
alias rdm='rake db:migrate'
alias rdtp='rake db:test:prepare'
alias rdr='rake db:rollback'
alias rjw='rake jobs:work'
alias rroutes='rake routes'
alias mroutes='rroutes | mate'
alias rmate='mate *.rb *.ru *.js Rakefile README* app config Gemfile* doc examples db lib lib_development Procfile public script spec test stories features vendor/plugins vendor/assets .gems .current_user .console_tools.rb'
alias fmate='rmate && rmate && rmate && rmate'
alias production='bin/production'
alias staging='bin/staging'
alias clip='pbcopy'

export PATH=/usr/local/bin:$PATH # http://stackoverflow.com/questions/6770649/repairing-postgresql-after-upgrading-to-osx-10-7-lion

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.