#oh-my-posh init pwsh | Invoke-Expression

# Starship: Inicialización rápida
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell --print-full-init | Out-String)
}

# Zoxide: Inicialización
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& zoxide init powershell | Out-String)
}

# Functions
function config { & git --git-dir="$HOME\.cfg/" --work-tree="$HOME" $args }

function lst {
    param([Parameter(ValueFromRemainingArguments=$true)]$RemainingArgs)
    & eza -lTL 2 --icons=auto --group-directories-first -h -- $RemainingArgs
}

# Esto le dice a PowerShell que trate a 'config' como si fuera 'git' 
# para efectos de autocompletado de comandos (checkout, commit, etc.)
if (Get-Command git -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -CommandName config -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        $unquotedWord = $wordToComplete -replace "['`"]", ""
        & git --git-dir="$HOME\.cfg/" --work-tree="$HOME" complete-alias $unquotedWord
    }
}


# Este bloque solo se ejecuta en PowerShell 7+
if ($PSVersionTable.PSVersion.Major -ge 7) {
  if (Get-Module -ListAvailable PSReadLine) {
      try {
          Set-PSReadLineOption -PredictionSource History
          Set-PSReadLineOption -PredictionViewStyle ListView
          # Esto permite completar sugerencias con la flecha derecha
          Set-PSReadLineKeyHandler -Key RightArrow -Function ForwardChar
          Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
      } catch {
          Write-Host "Nota: Actualiza PSReadLine para habilitar predicciones (Install-Module PSReadLine)" -ForegroundColor Yellow
      }
  }

}
#else {
    ## Comandos específicos para la versión 5.1 (opcional)
    #Write-Host "Cargando entorno legado (v5.1)..." -ForegroundColor Gray
#}


# Alias para gestionar dotfiles
function dotfiles { & git --git-dir='C:\Users\danys\.cfg' --work-tree='C:\Users\danys' $args }
