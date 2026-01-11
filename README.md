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

### Linux

#### Recommend

- Pyenv 
  
  > You could try ``curl -fsSL https://pyenv.run | bash``


####  Paste & use

```sh
wget -qO - https://raw.githubusercontent.com/Ebriopes/dotfiles/server/installer.sh | bash
```

### Windows

#### Requirements

Verify `ExecutionPolicy` to don't be ***restricted*** 

> [!TIP] How to disable _ExecutionPolicy_
> To change the *ExecutionPolicy* you need open an *Administrator Terminal* 
> 
> Where you will to validate your current status
> 
> `Get-ExecutionPolicy`
> 
> To change th "Restricted" status you can use 
> `Set-ExecutionPolicy RemoteSigned -Force` 


#### Recommended

- **NPM**

- Setup **SSH *Server***

- **Starship** 
  
  > You could try ``winget install --id Starship.Starship``


#### Paste & use

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/Ebriopes/dotfiles/server/installer.ps1 -OutFile $HOME\Downloads\dotfiles-installer.ps1
powershell -ExecutionPolicy Bypass -File $HOME\Downloads\dotfiles-installer.ps1
```

## Environment script

You can see the original environment configuration script here: [environment.sh](./environment-config.sh)

---

We are continue developing this page...
