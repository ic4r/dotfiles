#!/usr/bin/env bash

#------------------------------------------------------------------------------
# bitwarden - gpg - ssh private key 암/복호화
#------------------------------------------------------------------------------
# 매뉴얼: https://bitwarden.com/help/cli/
# 복호화:: bitwarden sso 비밀번호 -> bitwarden json 데이터추출 -> jq파싱: gpg  ascii 추출 -> gpg private key import -> gpg secret key 비밀번호: ssh private key복호화
# 암호화: ssh private key text -> gpg public key enc -> bitwarden 저장소 upload
#------------------------------------------------------------------------------

export DOTFILES=$HOME/dotfiles

# bitwarden API 키 설정 - https://vault.bitwarden.com/#/settings/account
BW_CLIENTID=
BW_CLIENTSECRET=
BW_PASSWORD=
BW_SESSION=


# 키값은 별도 추출하여 import
if [[ -f $DOTFILES/.key.env.sh ]]; then
    source $DOTFILES/.key.env.sh
else 
    echo ".key.env.sh file is not exist!"
fi


if [[ -z "$BW_CLIENTID" ]]; then echo "BW_CLIENTID is NULL. Export to env from bitwarden.com"; exit -1; fi
if [[ -z "$BW_CLIENTSECRET" ]]; then echo "BW_CLIENTSECRET is NULL. Export to env first."; exit -2; fi


# 설치
function bw_install() {
    if brew ls --versions bitwarden-cli > /dev/null; then
        echo "# The <bitwarden-cli> package is installed"
        bw update
    else
        # The package is not installed
        brew install bitwarden-cli
    fi
}

###################### 공통기능 ##################################

# 로그인
function bw_login() {
    bw login --apikey

    # 언락 (세션키 추출)
    UNLOCK=$( bw unlock --passwordenv BW_PASSWORD)
    export BW_SESSION=$(echo $UNLOCK | grep export | awk -F\" '{print $2}')
}


# 리스트 출력
function bw_list() {
    bw list items | jq
}

# item list
function bw_item_list() {
    bw list items | jq -r '.[] | .id + ", " + .name'
}


function bw_item() {
    if [[ $# -eq 0 ]]; then
        echo -e "usage: bw_item {item-id}  
            ==> bw get item $1 | jq"
        return -1
    fi
    bw get item $1 | jq
}


###################### END 공통기능 ##################################

# 아이템 생성 - 폴더 백업 
function bw_create_securefolder() {
# bw get template item 
# {
#   "organizationId": null,
#   "collectionIds": null,
#   "folderId": null,
#   "type": 1,
#   "name": "Item name",
#   "notes": "Some notes about this item.",
#   "favorite": false,
#   "fields": [],
#   "login": null,
#   "secureNote": null,
#   "card": null,
#   "identity": null,
#   "reprompt": 0
# }
# bw get template item.field
# {"name":"Field name","value":"Some value","type":0}

    if [[ $# -eq 0 ]]; then
        echo "usage: bw_create_securenote #path #notes #folderId "
        return -1
    fi

    # Item_ID가 넘어오면 edit
    ITEM_ID=""
    if [ -n "$4" ]; then
        ITEM_ID=$4
    fi


    BN=$(basename $1)
    ITEMS=()
    IDX=0
    RESULT=()

    for file in $(basename $1/*); do
        # 파일 사이즈가 5000 이상이면 패스
        if [[ $(wc -c $1/$file | awk '{print $1}') -gt 5000 ]]; then 
            echo "$file size: $(wc -c $1/$file) - size is too big! passed. "
            RESULT+=$(echo "{$file: $(wc -c $1/$file) passed}")
            continue
        fi

        ITEM=$(cat $1/$file | gpg -r $GPG_KEY -e | base64 -i -)
        ITEMS+=("{\"name\":\"$file\",\"value\":\"$ITEM\",\"type\":0}")
        ((IDX++))
        echo gpg encrypt : $IDX, $file, ${#ITEMS[@]}
        RESULT+=$(echo "{$file: gpg encrypt #$IDX}")
    done

    # echo $ITEMS | jq -s .

    # FIELD=
    # for i in ${ITEMS[@]}; do
    #     echo "$i"
    #     FIELD+=$(echo $i,)
    # done
    # | jq ".fields=[${FIELD%?}]" \

    TEMPLATE='{"organizationId":null,"collectionIds":null,"folderId":null,"type":1,"name":"Item name","notes":"Some notes about this item.","favorite":false,"fields":[],"login":null,"secureNote":null,"card":null,"identity":null,"reprompt":0}'
    # # bw get template item | jq ".folderId=\"$BW_FOLDER_ID\" | .type=2 | .name=\"$1\" | .notes=\"$2\"" \
    DATA=$(echo $TEMPLATE | jq ".folderId=\"$3\" | .type=2 | .secureNote.type=0 | .name=\"$BN\" | .notes=\"$2 - $RESULT\"" \
    | jq ".fields=($(echo $ITEMS | jq -s))" \
    | bw encode
    )
    if [[ -z "$ITEM_ID" ]]; then 
        echo $DATA | bw create item | jq
    else 
        echo $DATA | bw edit item $ITEM_ID | jq
    fi

}

# 지정한 폴더를 갈아 올림 (최초 1회 수행 - ID를 추출한다.)
function push_folder() {
    FOLDER=""
    if [[ -z $1 ]]; then
        echo "지정된 폴더의 모든 파일을 gpg암호화하여 bitwarden item으로 생성"
        echo "usage: pull_folder {folder} {option:itemId} {option:folderId} {option:Description}"
        echo "usage: pull_folder {folder} or bw_create_securenote {folder} {description} {folderId} {itemId}"
        
        return -1
    else
        FOLDER=$(readlink -f $1)
    fi

    local FID=""    # 폴더아이디
    if [ -z "$3" ]; then
        FID=$BW_FOLDER_ID
    else
        FID=$3
    fi

    local DESC=""    # 폴더아이디
    if [ -z "$4" ]; then
        DESC="$FOLDER folder backup"
    else
        DESC=$4
    fi

    echo "upload to bitwarden $FOLDER"

    # 중복 키 체크
    local BN=$(basename $FOLDER)
    local ITEM_ID=""
    if [ "$BN" = ".ssh" ]; then
        ITEM_ID=$BW_SSH_ITEM
    elif [ -n "$2" ]; then
        ITEM_ID=$2
    else
        ITEM_ID=""
    fi
    
    if [ -z "$ITEM_ID" ]; then 
        echo "Create New KEY: bw_create_securenote $FOLDER $DESC $FID "
        bw_create_securefolder $FOLDER $DESC $FID
    else
        echo "Update Exist KEY : bw_create_securenote $FOLDER $DESC $FID $ITEM_ID"
        bw_create_securefolder $FOLDER $DESC $FID $ITEM_ID
    fi

}

# 지정한 폴더를 복원
function pull_folder() {
    if [[ -z $1 ]]; then
        echo "지정된 폴더 복원"
        echo "usage: pull_folder {item-id}"
        return 1
    fi

    T1=$(bw get item $1)
    T2=$(echo $T1 | jq -r '.fields[] | .name')
    TN=$(echo $T1 | jq -r '.name')

    mkdir -p $TN && chmod 755 $TN 

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
}


# 단일 아이템 생성
function bw_create_securenote_one_file() {

    if [[ -z $1 ]]; then
        echo "usage: bw_create_securenote_one_file {filename} {note} {option:folderId} "
        echo "-> sample: bw_create_securenote_one_file test.sh \"key=>파일명, value=>gpg로 암호화 후, base64 인코딩된 문자열\""
        return 1
    fi

    # 파일 사이즈가 5000 이상이면 패스
    if [[ $(wc -c $1 | awk '{print $1}') -gt 5000 ]]; then 
        echo "$1 $(wc -c $1) - size is too big! passed. "
        return 1
    fi


    ITEM=$(cat $1 | gpg -r $GPG_KEY -e | base64 -i -)

    TEMPLATE='{"organizationId":null,"collectionIds":null,"folderId":null,"type":1,"name":"Item name","notes":"Some notes about this item.","favorite":false,"fields":[],"login":null,"secureNote":null,"card":null,"identity":null,"reprompt":0}'
    echo $TEMPLATE | jq ".folderId=\"$3\" | .type=2 | .secureNote.type=0 | .name=\"$(basename $1)\" | .notes=\"$2\"" \
    | jq ".fields=[{\"name\":\"$1\",\"value\":\"$ITEM\",\"type\":0}]" \
    | bw encode | bw create item > $1.bwitem

    cat $1.bwitem | jq
    echo RESULT FILE: $1.bwitem
}

# 단일 아이템 수정
function bw_edit_securenote_one_file() {

    if [[ -z $1 ]]; then
        echo "usage: bw_edit_securenote_one_file {filename} {itemId} {note} {option:folderId} "
        echo "-> sample: bw_edit_securenote_one_file test.sh 1234-5678 \"key=>파일명, value=>gpg로 암호화 후, base64 인코딩된 문자열\""
        return 1
    fi

    # 파일 사이즈가 5000 이상이면 패스
    if [[ $(wc -c $1 | awk '{print $1}') -gt 5000 ]]; then 
        echo "$1 $(wc -c $1) - size is too big! passed. "
        return 1
    fi


    ITEM=$(cat $1 | gpg -r $GPG_KEY -e | base64 -i -)

    TEMPLATE='{"organizationId":null,"collectionIds":null,"folderId":null,"type":1,"name":"Item name","notes":"Some notes about this item.","favorite":false,"fields":[],"login":null,"secureNote":null,"card":null,"identity":null,"reprompt":0}'
    echo $TEMPLATE | jq ".folderId=\"$4\" | .type=2 | .secureNote.type=0 | .name=\"$(basename $1)\" | .notes=\"$3\"" \
    | jq ".fields=[{\"name\":\"$1\",\"value\":\"$ITEM\",\"type\":0}]" \
    | bw encode | bw edit item $2 > $1.bwitem

    cat $1.bwitem | jq
    echo RESULT FILE: $1.bwitem
}

# 단일 아이템 복원
function bw_get_securenote_one_file() {
    if [[ -z $1 ]]; then
        echo "usage: bw_get_securenote_one_file {item-id}"
        return 1
    fi

    local T1=$(bw get item $1)
    local TN=$(echo $T1 | jq -r '.name')    # 파일명

    echo $T1 | jq ".fields[] | select(.name == \"$TN\") | .value" | sed 's/\"//g' |  base64 -d | gpg --batch --yes -o "$TN" -d -

    if [[ $TN == *.sh ]]; then
        chmod 755 $TN
        echo chmod 755 $TN
    fi
}


# bw_install 

bw_login && bw sync && bw_item_list

printf "\nfunction list:\n"
compgen -A function | egrep "bw_|_folder" -
printf "\f함수 명세출력: declare -f {function_name}\n"
echo