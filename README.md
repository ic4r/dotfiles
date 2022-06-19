# dotfiles
> 새로운 macos 환경에서 사용하던 환경과 최대한 가깝게 자동 세팅되도록 구성하는게 목표
* Github: https://github.com/ic4r/dotfiles


## 백업/복구 방법  

> **WARNING**  
> 작성자 이외의 환경에서는 `macos-init.sh`만 사용하세요. 다른 스크립트는 본인 환경에 맞게 수정하여 사용 바랍니다.

### macos 개발환경 최초 실행
```bash
$ git clone git@github.com:ic4r/dotfiles.git ~/dotfiles

$ sh ~/dotfiles/macos-init.sh
```
  
### 복구 실행방법
```bash
$ git clone git@github.com:ic4r/dotfiles.git ~/dotfiles

# 환경변수 파일 복원 (아래 환경변수 항목 참고)
$ cat << EOF > .key.env.sh
... 
EOF

$ sh ~/dotfiles/restore.sh
```

   
### 백업 실행방법

```bash
$ sh ~/dotfiles/backup.sh

# crontab에 자동 백업 등록: 
00 12 * * * yes | ~/dotfiles/backup.sh >> ~/tmp/log/dotfiles_backup.log 2>&1
```
> 1. `.key.env.sh` 파일 클립보드 카피 
> 2. 주요 파일체크 및 저장소 push 
> 3. icloud drive에 동기화


   
## 구성요소
> 환경변수, function_gpg.sh, function_bitwarden.sh
### 환경변수 파일(.key.env.sh)
```bash
EMAIL=
NAME=

# gpg key 
GPG_KEY="github에 등록된 gpg key"

# bitwarden API 키 설정 - https://vault.bitwarden.com/#/settings/account
BW_CLIENTID=
BW_CLIENTSECRET=

BW_PASSWORD=
BW_SESSION=

BW_GPG_ITEM="GPG 키가 저장된 ITEM ID"
BW_SSH_ITEM="SSH 키가 저장된 ITEM ID"
```
   
### gpg - GnuPG 암호화 ###
> - 키 생성: gpg --gen-key
>
> - 키서버에 업로드: gpg --keyserver hkps://keys.openpgp.org --send-keys <ID> (이메일인증까지)
> - 키 리스트: gpg --list-keys, gpg --list-secret-keys 
> - 키 삭제 (비밀키 먼저): gpg --delete-secret-keys <ID>, gpg --delete-key <ID>
>
> - 암호화: gpg -e -r <ID> <filename> 
> - 복호화: gpg -o <filename> -d <filename>.gpg
>
> - 공개키 export: gpg --armor --output <filename>.pub --export <ID>
> - 개인키 export: gpg -a -o <file>.secret --export-secret-keys <ID>
>
> - 공개키 import: gpg --import <filename>.pub (암호화가능)
> - 개인키 import: gpg --import <filename>.secret (복호화가능)
>
> - base64인코딩 후 백업: base64 -i <filename> | pbcopy 
 
#### gpg function 사용법 (function_gpg.sh) 
```bash
cd {gpg암호화 대상폴더}
source ~/dotfiles/function_gpg.sh

list_key         # 키 리스트 조회
list_secret_key  # 시크릿키 리스트 조회

enc_gpg {파일명}   # 지정한 파일을 gpg 공개키로 암호화
enc_all          # 현재 폴더의 모든 파일을 gpg 암호화
dec_gpg {파일명}   # 지정한 파일을 gpg 개인키로 복호화
dec_all          # 현재 폴더의 모든 gpg암호화 파일을 복호화
```


   
### bitwarden - gpg - ssh private key 암/복호화 
> Document: https://bitwarden.com/help/cli/
> - 복호화:: bitwarden master password -> bitwarden json 데이터추출 -> jq파싱: gpg  ascii 추출 -> gpg private key import -> gpg secret key 비밀번호: ssh private key복호화
> - 암호화: ssh private key text -> gpg public key enc -> bitwarden 저장소 upload

#### bitwarden function 사용법 (function_bitwarden.sh)
```bash
# bitwarden 로그인 & unlock & 세션키 export
source ~/dotfiles/function_bitwarden.sh

bw_list       # 저장된 모든 키를 출력
bw_item_list  # 저장된 모든 키를 [id, name] 형태로 출력

# 단일 파일을 gpg로 암호화하여 bitwarden에 저장 & 복구 (limit: 5000byte)
# {"key":"value"} => {"파일명":"file->gpg-encrypt->base64-encoding"}
bw_create_securenote_one_file {filename}  # 단일 파일 저장
bw_get_securenote_one_file {item-id}      # 단일 파일 복구

# 지정된 폴더의 모든 파일을 gpg로 암호화하여, bitwarden에 저장
# 폴더명: item name, 파일명: key, 파일암호화값: value
push_folder {절대경로}      # 폴더의 모든 파일 저장
pull_folder {item-id}     # 폴더 복구

bw_item {item-id}  # 아이템 상세 정보
```


### 저장된 gpg key와 .ssh 폴더의 복원 (gpg+bitwarden)
- 복구실행시 자동으로 기존설정을 덮어쓰므로 유의 (startup.sh에 포함되어 있음)
    * `source import_gpg_ssh.sh`
- gpg key 복원
    * local의 `gpg.pub`,`gpg.pri` 파일을 찾아서 복원하고, 없으면 bitwarden에 저장된 키를 받아서 복구
    * gpg public key는 gnupg keyserver에 공개되어 있음
    * gpg private key 복원시 gpg master password 필요
- .ssh 폴더 복원
    * `function_bitwarden.sh` 의 `push_folder ~/.ssh` 명령어로 gpg 암호화되어 bitwarden에 보관된 폴더의 복원
    * bitwarden 저장소 {"key"(->파일명): "value-> base64 decoding -> gpg decrypt"}
    * 개인키 복원시 파일 퍼미션 600으로 조정  

  
## CLI Tools & Apps
- asciinema : terminal record & play
- htop : process viewer. top 대체
- exa : ls 대체
- bat : cat 대체. 컬러풀 cat
- hexyl : od 대체. hex viewer
- fd : find 대체
- procs : ps 대체. process tree
- jq : json parser
- mas : appstore package manager
- nyancat : 고양이
- speedtest-cli : internet speed test
- youtube-dl : youtube downloader


- rbenv, pyenv, jenv : ruby, python, java env manager

- tig : graphical git history
- ngrok : inbound proxy

### container & k8s
- dive : docker image 분석 
- k9s : kubernetes cli dashboard
- octant : kubernetes dashboard to 127.0.0.1:7777
- lens : kubernetes desktop app dashboard 

### Apps
- wireshark : network analysis
- iterm2
- postman
- charles 
- iina : media player
- slack
- sourcetree : atlassian git client
- visual-studio-code : best editor
- ScreenBrush : 스크린에 낙서


## 현황
- [x] startup.sh 복구 스크립트
- [x] backup.sh 백업 스크립트
- [x] gpg 설정 및 github 연동 (`verified` mark)
- [x] bitwarden에 gpg암호화된 값 저장
- [x] 필수 application - brew로 설치경로 정리 후 스크립트 갱신
- [ ] .osx 환경설정
- [ ] 복구 테스트

## History
- 2022/06/19 오랫만에 환경백업 - 하려니 오류가 많이 발생해서 일부 수정

## REFERENCES

- Appkr.memo/dotfile만들기 https://blog.appkr.dev/work-n-play/dotfiles/ -> 
- Appkr/dotfiles https://github.com/appkr/dotfiles 
- github dotfiles https://dotfiles.github.io/
- even../GnuPG 암복호화 https://xmlangel.github.io/Gpg/ 
- johngrib/GnuPG 사인/검증까지 전반 https://johngrib.github.io/wiki/gpg/ 
- mathiasbynens/dotfiles (27k star) https://github.com/mathiasbynens/dotfiles 
- johngrib/dotfiles https://github.com/johngrib/dotfiles 
- lewagon/dotfiles https://github.com/lewagon/dotfiles
- 생계형 🐾者/dotfiles소개 https://yoonhona.github.io/posts/2020/08/14/dotfiles.html 
