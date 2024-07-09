#!/usr/bin/env bash

#------------------------------------------------------------------------------
# dotfiles
# Apple Silicon - m1 macos Restore Developer Configurations
# Github URL: https://github.com/ic4r/dotfiles
#------------------------------------------------------------------------------

read -p "CAUTION!! This script Rewite Home Folder. Really Execute Script? (y/n) " -n 1;
echo "";
if ! [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "=> Canceled."
  exit 1
fi;

export DOTFILES=$HOME/dotfiles
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

cd "$(dirname "${BASH_SOURCE}")"; # 스크립트가 실행되는 경로로 이동

### Private ###
if ! [[ -f $DOTFILES/.key.env.sh ]]; then
  echo "Not Exist key variables file ->  [.key.env.sh]"; exit;
else
  . .key.env.sh
  echo "Key Variables(.key.env.sh) Loading..."
fi


# dotfiles 업데이트
if [ -d "$DOTFILES/.git" ]; then
  git --work-tree="$DOTFILES" --git-dir="$DOTFILES/.git" pull origin main
fi

# Command Line Tool 설치 (기본명령어 설치 /Library/Developer/CommandLineTools/usr/bin)
xcode-select --install

# Homebrew 설치가 안되어 있으면 설치
if ! [[ -x "$(command -v brew)" ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' > ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"

  if ! [[ -x "$(command -v brew)" ]]; then
    echo "brew가 정상 설치되지 않았습니다. 필수 소프트웨어이므로 설치 후 재시도 해주세요."
    exit;
  fi
fi

# [Apple Silicon M1] rosetta 2 설치 (x86 기반의 프로그램을 m1-arm64 환경에서 구동해주는 해석기)
if [[ "arm64" == $(arch) ]]; then
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi


#------------------------------------------------------------------------------
# Git & github 설정
#------------------------------------------------------------------------------
brew install git git-crypt git-lfs

cat << EOF > ~/.gitconfig
[user]
    signingkey = $GPG_KEY
[commit]
    gpgsign = false
[init]
    defaultBranch = main
[color]
    ui = auto
[include]
    path = ~/.gitalias
EOF

# git global
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"

# git 한글파일명 처리
git config --global core.precomposeunicode true
git config --global core.quotepath false


#------------------------------------------------------------------------------
# Java 환경설정
#------------------------------------------------------------------------------
# For intel cpu (확인: arch -x86_64 java -version)
# brew install adoptopenjdk/openjdk/adoptopenjdk8 --cask
# brew install adoptopenjdk11 --cask

# For Apple silicon - M1 cpu (확인: arch -arm64 java -version)
#brew install zulu8 --cask
brew install zulu17 --cask

# brew install openjdk # openjdk 18. latest
# brew install openjdk@17

# jenv add $(/usr/libexec/java_home -v1.8)
jenv add $(/usr/libexec/java_home -V)  # 설치된 모든 JAVA Versions을 jenv 환경으로 등록
jenv versions

#------------------------------------------------------------------------------
# iterm2 & shell 환경설정
#------------------------------------------------------------------------------
function install_iterm2() {
  brew install "iterm2" --cask

  # Install - iterm2 shell integration and util
  curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash

  # Restore iterm2 config file
  cp com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist
}

function install_ohmyzsh() {

  #oh-my-zsh 설치
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

  # plugin
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting  #syntax-highlighting 플러그인 설치
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions  #autosuggestion plugin 설치
  git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions

  #powerlevel10k theme 다운로드
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

  sed -i '' '/^ZSH_THEME=/s/=.*$/="powerlevel10k\/powerlevel10k"/' .zshrc

}
# 최초설치시에만 실행
if ! [[ -d ~/.iterm2 ]]; then
  install_iterm2
fi
if ! [[ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom} ]]; then
  install_ohmyzsh
fi

#------------------------------------------------------------------------------
# vim 환경설정
#------------------------------------------------------------------------------
function install_vimrc() {
  # amix/vimrc를 통하여 기본환경 구성
  git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
  sh ~/.vim_runtime/install_awesome_vimrc.sh

  # Ctrl+f 단축키 매핑 변경 (기본설정은 페이지넘김 이슈)
  sed -i '' 's/C-f/C-l/' ~/.vim_runtime/vimrcs/plugins_config.vim

  # 옵션: vim brogrammer 색상테마 적용
  mkdir -p ~/.vim/colors && curl https://raw.githubusercontent.com/marciomazza/vim-brogrammer-theme/master/colors/brogrammer.vim > ~/.vim/colors/brogrammer.vim
  echo "colorscheme brogrammer" >> ~/.vimrc

}
function install_neovim() {
  brew install neovim
  # MesloLGS NF가 없는 경우
  # brew tap homebrew/cask-fonts
  # brew install font-meslo-lg-nerd-font

  echo -e 'Configure neovim. check .zshrc file..
    alias vim="nvim"
    alias vi="nvim"
    alias vimdiff="nvim -d"
    export EDITOR=/usr/local/bin/nvim
  '

  # spacevim 설치
  curl -sLf https://spacevim.org/install.sh | bash

  # spacevim theme 설치
  mkdir -p ~/.SpaceVim.d/colors
  curl -sSL https://gist.githubusercontent.com/subicura/91696d2da58ad28b5e8b2877193015e1/raw/6fb5928c9bda2040b3c9561d1e928231dbcc9184/snazzy-custom.vim -o ~/.SpaceVim.d/colors/snazzy-custom.vim

  #cp .SpaceVim.d/init.toml ~/.SpaceVim.d/
  ln -nfs $DOTFILES/.SpaceVim.d ~
}

read -p "neovim[n] or spacevim[s]. type (n/s) " -n 1;
echo ""

if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Installing Neovim..."
    install_neovim
elif [[ $REPLY =~ ^[Ss]$ ]]; then
    echo "Installing SpaceVim Plugin..."
    install_vimrc
elif ! [[ $REPLY =~ ^[NnSs]$ ]]; then
    echo "PASS Vim Config."
fi;


# 주요파일 Symbolic link로 강제 update
for name in gitignore gitalias zshrc; do
  ln -nfs $DOTFILES/.$name ~
done

#------------------------------------------------------------------------------
# Brewfile 복구: Install executables and libraries
#   - Brewfile 백업 -> brew bundle dump -f
#   - Brewfile 복구 -> brew bundle --file=${DOTFILES}/Brewfile
#------------------------------------------------------------------------------
brew bundle --file=${DOTFILES}/Brewfile


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

bw_install

# bitwarden에 저장된 gpg key를 추출한다.
sh import_gpg_ssh.sh

if ! [ 0 == "$?" ]; then echo "gpg key import fail."; exit; fi

if [ -e $DOTFILES/.ssh/dev ]; then
  chmod +x $DOTFILES/.ssh/dev
fi

# gnupg permission & for github
brew install pinentry-mac  # github gpg key pw-input window
mkdir -p ~/.gnupg
echo "pinentry-program /opt/homebrew/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf
chmod 600 ~/.gnupg/*
chmod 700 ~/.gnupg


### Private ###
#------------------------------------------------------------------------------
# Restore hammerspoon Config files
#------------------------------------------------------------------------------
# git clone git@github.com:ic4r/.hammerspoon.git ~/.hammerspoon
# 변경 => 설정코드는 dotfiles 폴더로 옮기고 symlink 걸어주도록 변경
brew install hammerspoon --cask
ln -nfs $DOTFILES/.hammerspoon ~



#------------------------------------------------------------------------------
# Application
#------------------------------------------------------------------------------
# brew install --cask lens     # docker/k8s admin ui & monitoring
# brew install --cask charles  # HTTP Comunication Proxy Hooking (HTTP 디버깅)
# brew install --cask "authy"  # OTP앱 - Authy Desktop 말고, 1/10 사이즈인 iPad용 authy 설치

# brew install --cask "shiftit"  # 윈도우 창 이동 -> hammerspoon script로 대체


# source .macos
echo -e "\n👏👏👏 macos configuration restore complete!!"

### Private ###
#------------------------------------------------------------------------------
# 복구 작업 완료 - backup.sh crontab에 등록 및 쓰잘데기 없는 알람기능
#------------------------------------------------------------------------------
# 작업완료를 알리는 고양이 - crontab 등록시 터미널경고가 발생하므로 사용자 액션을 넣어봄
#nyancat

function makecron() {
  # crontab에 백업 스크립트 및 로그 제거 스크립트 등록
  if ! [[ -n $(crontab -l | grep dotfiles/backup.sh) ]]; then
    # 로그폴더 생성 - .gitignore에 등록됨
    mkdir -p $DOTFILES/log

    # 매일 12시 정각 백업을 수행하고 로그를 남긴다.
    CRONJOB="00 12 * * * yes | $DOTFILES/backup.sh > $DOTFILES/log/backup_\$(date +\%m\%d_\%H\%M).log 2>&1"

    # 매일 12시10분에 30일 경과 로그를 삭제한다.
    LOGDJOB="10 12 * * * find $DOTFILES/log -maxdepth 1 -mtime +30 -type f -exec rm -f {} \;"

    # crontab 등록
    (crontab -l && echo "$CRONJOB" && echo "$LOGDJOB") | crontab -

    echo "[Preference > 보안 및 개인 정보 보호 > 개인 정보 보호 > 전체 디스크 접근 권한]에서 iTerm, crontab 권한 부여 필요!"
  fi
}



# 일기예보 CLI API (윈도우사이즈:125에 최적화) - pc 환경설정을 끝냈으면 날씨 확인하고 밖에 나가자.
curl https://wttr.in/seoul -H "Accept-Language: ko-KR"

# makecron
# echo -e "\n👻 crontab list:"
# crontab -l
