#!/usr/bin/env bash

# dotfiles 업데이트
if [ -d "$DOTFILES/.git" ]; then
#  git --work-tree="$DOTFILES" --git-dir="$DOTFILES/.git" pull origin main
  git fetch
fi


### Private ###
#------------------------------------------------------------------------------
# gpg & ssh 환경복구
# gpg 키는 bitwarden에 암호화되어 보관 (bitwarden -> base64 -> gpg 복구 -> ssh key 복구) 
#------------------------------------------------------------------------------
function bw_install() {
    if brew ls --versions bitwarden-cli > /dev/null; then
        echo "# The <bitwarden-cli> package is installed"
        bw update
    else
        # The package is not installed
        brew install bitwarden-cli
    fi
}

#bw_install

# bitwarden에 저장된 gpg key & .ssh 폴더 복구
sh import_gpg_ssh.sh

if ! [ 0 == "$?" ]; then echo "gpg key import fail."; else echo "gpg key import success!" exit; fi

if [ -e $DOTFILES/.ssh/dev ]; then
  chmod +x $DOTFILES/.ssh/dev
fi



# source .macos
echo -e "\n👏👏👏 macos configuration restore complete!!"

### Private ###
#------------------------------------------------------------------------------
# 복구 작업 완료 - backup.sh crontab에 등록 및 쓰잘데기 없는 알람기능
#------------------------------------------------------------------------------
# 작업완료를 알리는 고양이 - crontab 등록시 터미널경고가 발생하므로 사용자 액션을 넣어봄
nyancat

# 일기예보 CLI API (윈도우사이즈:125에 최적화) - pc 환경설정을 끝냈으면 날씨 확인하고 밖에 나가자.
curl https://wttr.in/seoul -H "Accept-Language: ko-KR"

