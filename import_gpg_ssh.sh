#!/usr/bin/env bash

export DOTFILES=$HOME/dotfiles

# (bitwarden api 작동하지 않을때 수동으로 인코딩 키 카피하여 처리)
# GnuPG public key import if file exist 
if [[ -f gpg.pub ]]; then
    cat gpg.pub | sed 's/\"//g' | base64 -d | gpg --import --
    gpg --list-keys
fi

# GnuPG private key import if file exist
if [[ -f gpg.pri ]]; then
    cat gpg.pri | sed 's/\"//g' | base64 -d > gpg.secret.tmp
    gpg --import gpg.secret.tmp
    rm -f gpg.secret.tmp
    gpg --list-secret-keys
    exit
fi

# gpg key import 후, 키 상태 [unknown]을 [ultimate]로 변경하는 방법
# https://unix.stackexchange.com/questions/407062/gpg-list-keys-command-outputs-uid-unknown-after-importing-private-key-onto
# gpg --edit-key user@useremail.com
# trust -> 5 -> save

# bw file check
BW_FUNC=$DOTFILES/function_bitwarden.sh
if [[ -f $BW_FUNC ]]; then
    source $BW_FUNC
else 
    echo "$BW_FUNC file is not exist!"
    exit 1
fi

#------------------------------------------------------------------------------
# gpg - GnuPG 암호화 ###
#------------------------------------------------------------------------------
# - 키 생성: gpg --gen-key
# 
# - 키서버에 업로드: gpg --keyserver hkps://keys.openpgp.org --send-keys <ID> (이메일인증까지)
# - 키 리스트: gpg --list-keys, gpg --list-secret-keys 
# - 키 삭제 (비밀키 먼저): gpg --delete-secret-keys <ID>, gpg --delete-key <ID>
# 
# - 암호화: gpg -r <ID> -e <filename>
# - 복호화: gpg -o <복호화파일명> -d <암호화된파일명>.gpg
# 
# - 공개키 export: gpg --armor --output <filename>.pub --export <ID>
# - 개인키 export: gpg -a -o <file>.secret --export-secret-keys <ID>
# 
# - 공개키 import: gpg --import <filename>.pub (암호화가능)
# - 개인키 import: gpg --import <filename>.secret (복호화가능)
# 
# - base64인코딩 후 백업: base64 -i <filename> | pbcopy 
#------------------------------------------------------------------------------
# using gpg key in bitbucket: https://confluence.atlassian.com/bitbucketserver/using-gpg-keys-913477014.html

#------------------------------------------------------------------------------
# gpg key import
#------------------------------------------------------------------------------
if [[ -z "$BW_SESSION" ]]; then echo "Bitwarden Login Failed!! (우회하려면 gpg.pub/pri 키를 수작업 카피)"; exit -99; fi

# GnuPG public key import
if [[ -f gpg.pub ]]; then
    cat gpg.pub | sed 's/\"//g' | base64 -d | gpg --import --
else 
    bw get item $BW_GPG_ITEM | jq '.fields[] | select(.name|contains("Pub")) | .value' | sed 's/\"//g' | base64 -d | gpg --import --
fi

# GnuPG private key import
if [[ -f gpg.pri ]]; then
    cat gpg.pub | sed 's/\"//g' | base64 -d > gpg.secret.tmp
else
    bw get item $BW_GPG_ITEM | jq '.fields[] | select(.name|contains("Pri")) | .value' | sed 's/\"//g' | base64 -d > gpg.secret.tmp
fi

gpg --import gpg.secret.tmp
rm -f gpg.secret.tmp

echo -e "\n[[ gpg key import complete! ]]\n"

#------------------------------------------------------------------------------
# .ssh 폴더 복구 (ssh key 포함)
#------------------------------------------------------------------------------

T1=$(bw get item $BW_SSH_ITEM)
T2=$(echo $T1 | jq -r '.fields[] | .name')
TN=$(echo $T1 | jq -r '.name')

mkdir -p $TN && chmod 700 $TN 
ln -nfs $DOTFILES/$TN ~

for f in $(echo $T2); do 
    echo $f
    echo $T1 | jq ".fields[] | select(.name == \"$f\") | .value" | sed 's/\"//g' |  base64 -d | gpg --batch --yes -o "$TN/$f" -d -
     
    if ! [[ $f == *.* ]] || [[ $f == *.pem ]]; then 
        chmod 600 $TN/$f
        echo chmod 600 $TN/$f
    elif [[ $f == *.sh ]]; then
        chmod 755 $TN/$f
        echo chmod 755 $TN/$f
    else
        chmod 644 $TN/$f
        echo chmod 644 $TN/$f
    fi
    echo
done

echo -e "\n[[ .ssh restore complete! ]]\n"

echo ------------------------------------------------------------------------------
echo "# gpg key import 후, 키 상태 [unknown]을 [ultimate]로 변경"
echo "$ gpg --edit-key $EMAIL \n # trust -> 5 -> save"
echo ------------------------------------------------------------------------------
