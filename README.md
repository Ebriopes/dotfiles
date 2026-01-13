# Dotfiles backup

Hi to my repo backup with configurations to all my environment

Current config backups

+ ***Neovim***
+ *zsh*
+ Rofi
+ Unicode Rxvt
+ hyperx
+ kitty  

---

## Installing

Here you will find the scripts to install my environment config

### Pre-requirements

Have installed:

- Git 
  
  > You could try `winget install --id Git.Git`

#### Recommend

- **NPM**

- Setup **SSH *Server***


### Linux

#### Recommend

- Pyenv 
  
  > You could try ``curl -fsSL https://pyenv.run | bash``


####  Paste & use

```sh
bash <(wget -qO - https://raw.githubusercontent.com/Ebriopes/dotfiles/server/assets/scripts/installer.sh)
```

### Windows

#### Requirements

Verify `ExecutionPolicy` to don't be ***restricted*** 

> [!TIP] How to disable _ExecutionPolicy_  
>  
> To change the *ExecutionPolicy* you need  
> - Open an *Administrator Terminal*  
> 
> - Where you will to validate your current status
> `Get-ExecutionPolicy`  
> 
> - To change the "Restricted" status you can use 
> `Set-ExecutionPolicy RemoteSigned -Force` 


#### Recommended

- **Starship** 
  
  > You could try ``winget install --id Starship.Starship``


#### Paste & use

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/Ebriopes/dotfiles/server/assets/scripts/installer.ps1 -OutFile $HOME\Downloads\dotfiles-installer.ps1
powershell -ExecutionPolicy Bypass -File $HOME\Downloads\dotfiles-installer.ps1
```

## Environment script

You can see the original environment configuration script here: [base_install.sh](./assets/scripts/base_install.sh)

---

We are continue developing this page...

