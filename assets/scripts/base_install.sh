##############################################
#                                            # 
#  Script to install programs and configure  #
#  the environment to a fresh installation   #
#                                            #
##############################################

##############################
# Debian based distro (PopOS)
################

# First update of current OS
sudo apt update && sudo apt upgrade

# required packages to add GPG keys
sudo apt install wget gpg

# Add keys to private programs like google or VSCode
# VSCODE
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# GOOGLE-CHROME
sudo wget -O- https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /usr/share/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

# NEOVIM
sudo add-apt-repository ppa:neovim-ppa/stable

# Spotify (Debian based)
curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

# Update repositories
sudo apt update

# Install all left packages
sudo apt install \
  code\
  emacs\
  fd-find\
  git\
  golang\
  google-chrome-stable\
  kitty\
  neovim\
  python-pip\
  python2\
  python3-pip\
  python3\
  ranger\
  ripgrep\
  rofi\
  rxvt-unicode\
  spotify\
  transmission\
  wget\
  zsh-autosuggestions\
  zsh-syntax-highlighting\
  zsh\

#############################
# Install and configure ZSH #
#############################

# Install Oh-My-ZSH
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install extra plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

### Install fonts
if [ ! -d "$HOME/.local/share/fonts" ]; then
  mkdir -p $HOME/.local/share/fonts
fi

fonts=("Regular" "Bold" "Italic" "Bold Italic")

for type in $fonts; do
  wget -nv -P $HOME/.local/share/fonts/ "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS NF ${type}.ttf"
done

fc-cache -f
### End fonts

# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
nvm install stable

# Change default editor
sudo update-alternatives --config editor

# Set credentials to authenticate to Git in the next steps
ssh-keygen -t ed25519 -C "antonio.vargasrosales@gmail.com"
# If you are using a legacy system that doesn't support the Ed25519 algorithm, use:
#ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
# Print the public key to be integrated in some git plataform
echo -e "SSH public key \nStart -----------------------\n"
cat $HOME/.ssh/id_ed25519.pub
echo "End -------------------------"

# Config git
git config --global user.email antonio.vargasrosales@gmail.com
git config --global user.name ebriopes
git config --global init.defaultBranch main

# DOTFILES 
# Set alias to call my dotfiles
alias config="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
# add config folder to gitignora, this avoid recursive errors
echo ".cfg" >> $HOME/.gitignore

git clone --bare https://github.com/Ebriopes/dotfiles.git $HOME/.cfg






#######################
# Configure work base #
#######################

# Install Docker/Docker-compose
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

## Debian
#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

#echo \
  #"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  #$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

## Ubuntu
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu   $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

## general
sudo usermod -aG docker $USERNAME

# Configure node
nvm install 12
npm i -g npmrc
npm config set registry https://registry.npmjs.org/
npmrc -c kavak
npm config set registry https://npm.kavak.services
npmrc -c public
npm config set registry https://registry.npmjs.org/
npmrc kavak

# Install AWS credentials
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && rm awscliv2.zip
sudo ./aws/install
aws --version
aws configure --profile olimpo-dev 

# Install backend packages
npmrc public
npm install -g serverless@2.18.0
npm i -g serverless --unsafe-perm

# Finish installing all npm dependencies for Olimpo
npmrc kavak
npm ci

# Test that everything is ok
nx serve backend-api-rest

# Set up local DB
npm run db:start-bg

