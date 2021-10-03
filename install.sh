#!/bin/bash

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "install.sh ran at $(date) from $(SCRIPT_DIR)" >> ~/install.log

# Add source for RCM
wget https://thoughtbot.com/thoughtbot.asc && \
  sudo apt-key add - < thoughtbot.asc && \
  echo "deb https://apt.thoughtbot.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/thoughtbot.list

echo "Installing apt things" >> ~/install.log
# Install RCM
sudo apt-get update
sudo apt-get install -yq rcm zsh

echo "Installing fzf" >> ~/install.log
# Install fzf from source
git clone --depth 1 --branch 0.20.0 https://github.com/junegunn/fzf.git ~/.fzf && \
  ~/.fzf/install --all

echo "Installing tmux from source" >> ~/install.log
# Build tmux from source
TMUX_VERSION=3.2a && \
  wget https://github.com/tmux/tmux/releases/download/$TMUX_VERSION/tmux-$TMUX_VERSION.tar.gz && \
  tar xf tmux-$TMUX_VERSION.tar.gz && \
  rm -f tmux-$TMUX_VERSION.tar.gz && \
  cd tmux-$TMUX_VERSION && \
  ./configure && \
  make && \
  sudo make install && \
  cd - && \
  sudo rm -rf /usr/local/src/tmux-\* && \
  sudo mv tmux-$TMUX_VERSION /usr/local/src

echo "Installing oh my zsh if it does not exist" >> ~/install.log
# Install oh-my-zsh
[ ! -d "~/.oh-my-zsh" ] && sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended

echo "Installing dotfiles with rcup" >> ~/install.log
rcup -d $SCRIPT_DIR -f -B docker vscode_shell tmux.conf zshrc gitconfig gitignore

echo "Installing solargraph" >> ~/install.log
gem install solargraph