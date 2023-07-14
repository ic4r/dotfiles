#!/usr/bin/env bash

DOTFILES=$HOME/dotfiles

cd "$(dirname "${BASH_SOURCE}")";

# gpg key backup (bitwarden - gpg-password)
# 필요시 직접수행: gpg export -> bw create item

## hosts file backup
cp /etc/hosts .ssh/hosts
mkdir -p .kube
cp $HOME/.kube/config* $DOTFILES/.kube 2>/dev/null

# .ssh folder backup (gpg->bitwarden - bitwarden-password) 
echo ".ssh 폴더 백업"
FOLDER=$(readlink -f .ssh)
DESC="$(date '+%Y-%m-%d %H:%M') $HOST $FOLDER"
FID=$BW_FOLDER_ID
ITEMID=$BW_SSH_ITEM

source ~/dotfiles/function_bitwarden.sh && bw_create_securefolder $FOLDER "$DESC" $FID $ITEMID

#push_folder ~/.ssh
echo -e "[.ssh backup]\n"
echo "실패시, gpg --edit-key <KEY_ID> -> gpg> trust -> 5"

# icloud Documents 동기화폴더에도 복사해 주자. 
rsync -avh $DOTFILES ~/Documents/ --exclude .git --exclude log/ --delete
echo -e "[rsync to icloud documents backup Complete!]\n"

echo "$(date "+%Y-%m-%d %H:%M") Backup to https://github.com/ic4r/dotfiles Complete!"

