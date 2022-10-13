#!/usr/bin/env bash

ssh-keygen -t ed25519 -C "antonio.vargasrosales@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo "The next is your public key to you add it in github, before continue: "
cat ~/.ssh/id_ed25519.pub
read -p "Press enter to continue "

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
git clone --bare git@github.com:Ebriopes/dotfiles.git $HOME/.cfg
config checkout
