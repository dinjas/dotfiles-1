#!/bin/bash

sudo ()
{
    [[ $EUID = 0 ]] || set -- command sudo "$@"
    "$@"
}

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "system_install.sh ran at $(date) from $SCRIPT_DIR" >> $SCRIPT_DIR/install.log

echo "Installing packages" >> $SCRIPT_DIR/install.log

if [ `which apt` ]; then
  
  # Add source for RCM
  wget https://thoughtbot.com/thoughtbot.asc && \
    sudo apt-key add - < thoughtbot.asc && \
    echo "deb https://apt.thoughtbot.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/thoughtbot.list

  # Install RCM
  sudo apt-get update
  sudo apt-get install -o Dpkg::Options::="--force-confold" -yq rcm netcat zsh iproute2

  # Install Kubectl
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

  # Install Helm
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

  # Install kubectx + kubens
  sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
  sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

  echo "Installing tmux from source" >> $SCRIPT_DIR/install.log
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
elif [ `which apk` ]; then
   apk add tmux rcm zsh iproute2
else
   echo "UNKNOWN LINUX DISTRO"
   exit 1
fi
