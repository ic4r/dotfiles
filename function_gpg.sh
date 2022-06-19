#!/usr/bin/env bash

export DOTFILES=$HOME/dotfiles

if [[ -f $DOTFILES/.key.env.sh ]]; then
    source $DOTFILES/.key.env.sh
else 
    echo ".key.env.sh file is not exist!"
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

function list_key() {
    gpg --list-keys
}

function list_secret_key() {
    gpg --list-secret-keys
}


# file -> gpg encrypt -> base64 -> bw text field
function enc_gpg() {
    echo $1
    local target=$(basename $1)
    local p=$(pwd)
    echo $p/$target

    gpg -o $p/$target.gpg --recipient $GPG_KEY --encrypt $1
    base64 -i $p/$target.gpg > $p/$target.gpg.b64
    cat $p/$target.gpg.b64
    rm -f $p/$target.gpg 
}

# 현재 경로 모든 파일의 gpg 암호화 파일 생성
function enc_all() {
    for file in $(basename ./*); do
        if [[ ! $file == *.b64 ]]; then
            enc_gpg $file
        fi
    done
}


# bw text field -> base64 -> gpg decrypt -> file
function dec_gpg() {
    echo $1
    local target=$(basename $1)

    base64 -d $1 | gpg -o ${target/.gpg.b64/} --decrypt -

    # .sh 파일이면 실행권한을 부여한다.
    if [[ ${target/.gpg.b64/} == *.sh ]]; then
        chmod +x ${target/.gpg.b64/}
    fi
}

# 현재 경로 모든 gpg 암호화 파일을 복원
function dec_all() {
    for file in $(basename ./*); do
        if [[ $file == *.b64 ]]; then
            dec_gpg $file
        fi
    done
}