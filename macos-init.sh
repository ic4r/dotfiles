#!/usr/bin/env bash

#------------------------------------------------------------------------------
# New m1 macos first install
#------------------------------------------------------------------------------
read -p "신규 macos 개발환경을 빠르게 구성할 수 있지만, 쓸데없는 기능까지 설치될 수 있습니다. 진행할까요? (y/n) " -n 1;
echo "";
if ! [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "=> 취소 되었습니다."
  exit 1
fi;

export DOTFILES=$HOME/dotfiles
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

cd "$(dirname "${BASH_SOURCE}")"; # 스크립트가 실행되는 경로로 이동

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

brew install openjdk # openjdk 18. latest 
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
if ! [[ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom} ]]; then
  install_iterm2
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
# 최초설치시에만 실행
if [[ ! -e ~/.viminfo ]]; then
  # install_vimrc
  install_neovim
fi

# 주요파일 Symbolic link로 강제 update
for name in gitignore gitalias zshrc; do
  ln -nfs $DOTFILES/.$name ~
done

#------------------------------------------------------------------------------
# Brewfile 복구: Install executables and libraries
#   - Brewfile 백업 -> brew bundle dump -f
#   - Brewfile 복구 -> brew bundle --file=${DOTFILES}/Brewfile
#------------------------------------------------------------------------------
brew bundle --file=${DOTFILES}/Brewfile-init

#------------------------------------------------------------------------------
# Application
#------------------------------------------------------------------------------
# brew install --cask lens     # docker/k8s admin ui & monitoring
# brew install --cask charles  # HTTP Comunication Proxy Hooking (HTTP 디버깅)
# brew install --cask "authy"  # OTP앱 - Authy Desktop 말고, 1/10 사이즈인 iPad용 authy 설치

# brew install --cask "shiftit"  # 윈도우 창 이동 -> hammerspoon script로 대체


# source .macos
echo -e "\n👏👏👏 macos configuration restore complete!!"
