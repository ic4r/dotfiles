#!/usr/bin/env bash

#------------------------------------------------------------------------------
# New m1 macos first install
# 사용자의 동의를 받아 진행 여부 결정
# 필수 환경 변수 설정
# 주요 설정 파일들을 백업하고 업데이트
# Xcode Command Line Tools 설치
# Homebrew 설치 및 설정
# Apple Silicon M1 기반 Mac에서 Rosetta 2 설치
# Git 및 관련 도구 설치, Git 설정
# Java 환경 설정 및 jenv를 통한 Java 버전 관리
# Brewfile을 이용한 소프트웨어 일괄 설치
# iTerm2 및 Zsh 환경 설정, Oh My Zsh 및 테마, 플러그인 설치
# Neovim 설치 및 설정
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

# 주요파일 Symbolic link로 강제 update
for name in gitignore gitalias zshrc zprofile; do
  echo "cp ~/.$name ~/.$name.bak"
  echo "cp -f $DOTFILES/.$name ~"
  cp ~/.$name ~/.$name.bak
  cp -f $DOTFILES/.$name ~
done

cp -f $DOTFILES/.zshrc-init ~/.zshrc

# Command Line Tool 설치 (기본명령어 설치 /Library/Developer/CommandLineTools/usr/bin)
xcode-select --install

# $?는 마지막 실행된 명령어의 종료 상태를 나타냅니다.
# 0이면 성공, 0이 아니면 에러. 특정 에러 코드(예: 130)는 이미 설치되어 있거나 설치 중임을 나타낼 수 있습니다.
if [ $? -ne 0 ]; then
    # xcode-select의 상태를 확인합니다.
    xcode_select_status=$(xcode-select -p &> /dev/null; echo $?)
    
    # xcode-select -p의 종료 상태가 0이면, Command Line Tools가 이미 설치되어 있음을 의미합니다.
    if [ $xcode_select_status -eq 0 ]; then
        echo "Command Line Tools가 이미 설치되어 있습니다. 계속 진행합니다."
    else
        echo "Command Line Tool 설치에 실패했습니다. 스크립트를 종료합니다."
        echo "설치 후 다시 실행해주세요. => xcode-select --install"
        exit 1
    fi
fi

# Homebrew 설치가 안되어 있으면 설치
if ! [[ -x "$(command -v brew)" ]]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"

  if ! [[ -x "$(command -v brew)" ]]; then
    echo "brew가 정상 설치되지 않았습니다. 필수 소프트웨어이므로 설치 후 재시도 해주세요."
    exit;
  fi
else 
  brew info
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

echo "Set git config later.."
echo "git config --global user.name [NAME]"
echo "git config --global user.email [EMAIL]"

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
# Brewfile 복구: Install executables and libraries
#   - Brewfile 백업 -> brew bundle dump -f
#   - Brewfile 복구 -> brew bundle --file=${DOTFILES}/Brewfile
#------------------------------------------------------------------------------
brew bundle --file=${DOTFILES}/Brewfile-init


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
# if ! [[ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom} ]]; then
#   install_iterm2
# fi

read -p "install iterm2? (y/n) " -n 1;
echo "";
if ! [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "install_iterm2 canceled."
else 
  install_iterm2
fi;

#------------------------------------------------------------------------------
# vim 환경설정
#------------------------------------------------------------------------------
function install_neovim() {
  brew install neovim
  # MesloLGS NF가 없는 경우
  brew tap homebrew/cask-fonts
  brew install font-meslo-lg-nerd-font

  echo -e 'Configure neovim. check .zshrc file.. 
    alias vim="nvim" 
    alias vi="nvim" 
    alias vimdiff="nvim -d" 
    export EDITOR=/usr/local/bin/nvim 
  '
  # spacevim 설치
  curl -sLf https://spacevim.org/install.sh | bash

  #cp .SpaceVim.d/init.toml ~/.SpaceVim.d/
  cp -Rf $DOTFILES/.SpaceVim.d ~
}
# 최초설치시에만 실행
# if [[ ! -e ~/.viminfo ]]; then
#   # install_vimrc
#   install_neovim
# fi
read -p "install neovim? (y/n) " -n 1;
echo "";
if ! [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "install_neovim canceled."
else 
  install_neovim
fi;



# source .macos
echo -e "\n👏👏👏 macos configuration restore complete!!"
