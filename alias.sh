#!/usr/bin/env bash

# Get External IP / Internet Speed
alias myip="curl https://ipinfo.io/json" # or /ip for plain-text ip
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"

# Quickly serve the current directory as HTTP
alias serve='ruby -run -e httpd . -p 8000' # Or python -m SimpleHTTPServer :)


# alias
alias ls='ls -G'
alias df='df -P'
alias ll='ls -Gl'
alias df='df -Ph'
alias f='open -a Finder ./'
alias ttop="top -R -F -s 10 -o rsize"
alias flushDNS='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder '
alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"
alias dig='dig +noall +answer $@'
alias nslookup='dig +noall +answer $@'
alias su='sudo su'
alias bup='brew update ; brew upgrade ; brew cleanup'
alias history='history -i'
alias procs='procs --thread --tree'

# log tailing to browser 
alias logw='npx logscreen'
