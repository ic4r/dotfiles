#!/usr/bin/env bash

DOTFILES=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE}")";

#read -p "홈폴더의 설정파일들을 백업하시겠습니까? (y/n) " -n 1;
#echo "";
#if ! [[ $REPLY =~ ^[Yy]$ ]]; then
#    echo "=> 취소 되었습니다."
#    exit 1
#fi;

echo
echo ------------------------------------------------------------------------------
echo             Starting dotfiles backup $(date "+%Y-%m-%d %H:%M") 
echo ------------------------------------------------------------------------------
echo "Backup .key.env.sh to Private Repository!! Copied to Clipboard!"
echo "cat .key.env.sh | pbcopy"



# 주요파일 check
for name in gitignore gitalias zshrc; do
    if ! [[ -f $DOTFILES/.$name ]]; then 
        echo ".$name is not exist!!"
        exit -1
    fi
done
echo -e "[Check Complete!]\n"

#------------------------------------------------------------------------------
# Install executables and libraries
# Brewfile 백업 -> brew bundle dump -f
# Brewfile 복구 -> brew bundle --file=${DOTFILES}/Brewfile
#------------------------------------------------------------------------------
brew bundle dump -f
echo -e "[brew bundle Complete!]\n"


# iterm2 config file
echo -e "[com.googlecode.iterm2.plist PASSED!]\n"
#cp ~/Library/Preferences/com.googlecode.iterm2.plist $DOTFILES


# dotfiles push
if [[ $(git status --porcelain) ]]; then
  git add --all 
  git commit -m "$(date "+%Y-%m-%d %H:%M") $1"
  git push
  echo -e "[github push Complete!]\n"
else
    echo "git이 최신 상태입니다."
fi

# backup hammerspoon Config files => dotfiles 하위로 경로 변경
# cd ~/.hammerspoon
# git add .
# git commit -m "$(date "+%Y-%m-%d %H:%M") Backup"
# git push
#echo -e "[hammerspoon backup PASSED!]\n"

# gpg key backup (bitwarden - gpg-password)
# 필요시 직접수행: gpg export -> bw create item

## hosts file backup
cp /etc/hosts .ssh/hosts
cp $HOME/.kube/* $DOTFILES/.kube 2>/dev/null

# .ssh folder backup (gpg->bitwarden - bitwarden-password) 
# 필요시 아래 스크립트 직접수행
# source ~/dotfiles/function_bitwarden.sh && push_folder ~/.ssh
echo "source ~/dotfiles/function_bitwarden.sh && push_folder ~/.ssh"
echo -e "[.ssh backup PASSED!]\n"

# icloud Documents 동기화폴더에도 복사해 주자. 
rsync -avh $DOTFILES ~/Documents/ --exclude .git --exclude log/ --delete
echo -e "[rsync to icloud documents backup Complete!]\n"

echo "$(date "+%Y-%m-%d %H:%M") Backup to https://github.com/ic4r/dotfiles Complete!"

