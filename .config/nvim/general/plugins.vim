call plug#begin()
  " Themes
  Plug 'arcticicestudio/nord-vim'
  Plug 'sainnhe/everforest'

  " Highlighting support
  "Plug 'sheerun/vim-polyglot'

  " Airline
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  " Tree
  Plug 'nvim-neo-tree/neo-tree.nvim'

  " Commenter
  Plug 'preservim/nerdcommenter'

  " Icons
  Plug 'ryanoasis/vim-devicons'

  " Pairing
  Plug 'tpope/vim-surround'

  " Tags
  Plug 'ludovicchabant/vim-gutentags', { 'on': [] }

  " Linter
  "Plug 'dense-analysis/ale'

  """ Extras
  " Battery
  "Plug 'lambdalisue/battery.vim'
  
  " Narrowing
  Plug 'chrisbra/NrrwRgn'

  " Float terminal
  Plug 'voldikss/vim-floaterm', { 'on': [] }

  if has('nvim')
      " Utils
      Plug 'nvim-lua/plenary.nvim', { 'commit': '37604d9' }

    " Tree
    "Plug 'preservim/nerdtree'
    
    " Notifications
    Plug 'rcarriga/nvim-notify', { 'tag': 'v3.14.1'}

    " Icons
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'nvim-mini/mini.nvim'

    " RipGrep
    Plug 'duane9/nvim-rg'

    if has('unix')
      Plug 'kevinhwang91/rnvimr'
    endif

  """""""""""""""""""""""
  " NeoVim Ver:  0.3.0+ "
  """""""""""""""""""""""
    if has('nvim-0.3.1')
      Plug 'dstein64/vim-startuptime'
    endif

  """""""""""""""""""""""
  " NeoVim Ver:  0.5+   "
  """""""""""""""""""""""
    if has('nvim-0.5')
      " Utils
      Plug 'MunifTanjim/nui.nvim'

    endif

  """""""""""""""""""""""
  " NeoVim Ver:  0.6.0+ "
  """""""""""""""""""""""
    if has('nvim-0.6.0')
      " Linter
      Plug 'mfussenegger/nvim-lint'

      " Language Server Protocols
      Plug 'antosha417/nvim-lsp-file-operations'
    endif
    
  """""""""""""""""""""""
  " NeoVim Ver:  0.7.0+ "
  """""""""""""""""""""""
    if has('nvim-0.7.0')
      " Language Server Protocols
      Plug 'hrsh7th/cmp-nvim-lsp' "LSP source for nvim-cmp
      "Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }

      " For luasnip users.
      Plug 'saadparwaiz1/cmp_luasnip'

      Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
    endif

  """""""""""""""""""""""
  " NeoVim Ver:  0.8.0+ "
  """""""""""""""""""""""
    if has('nvim-0.8.0')
      " Utils
      Plug 'nvim-lua/plenary.nvim'

      " Autocompletion
      Plug 'hrsh7th/nvim-cmp'  "Autocompletion plugin
    endif

  """""""""""""""""""""""
  " NeoVim Ver:  0.9.0+ "
  """""""""""""""""""""""
    if has('nvim-0.9.0')
      " Language Server Protocols
      Plug 'nvimdev/lspsaga.nvim'

        if has('nvim-0.9.4')
          " Utils
          Plug 'folke/snacks.nvim'
        endif
    endif

  """"""""""""""""""""""""
  " NeoVim Ver:  0.10.4+ "
  """"""""""""""""""""""""
    if has('nvim-0.10.4')
      " Language Server Protocols
      Plug 'nvimdev/lspsaga.nvim'

      " Notifications
      Plug 'rcarriga/nvim-notify'
    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " === ===== ===   CONFLICT PLUGIN VERSIONS   === ===== === "
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    """""""""""""""""""""
    " NeoVim   v0.11.0+ "
    """""""""""""""""""""
    if has('nvim-0.11.0')
      " Highlighting support
      Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'main' } ", {'do': ':TSUpdate'}

      " File Manager
      Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'main' }

      " Language Server Protocols
      Plug 'neovim/nvim-lspconfig', { 'branch': 'master'}

      " Manager installer
      Plug 'williamboman/mason-lspconfig.nvim'

      " Search engine
      Plug 'nvim-telescope/telescope.nvim'

      "  Opencode integration
      Plug 'nickjvandyke/opencode.nvim'

    else
      """""""""""""""""""""
      " v0.10.4 ~ v0.11.0 "
      """""""""""""""""""""
      if has('nvim-0.10.4')
        " Highlighting support
        Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'master' }

        " Language Server Protocols
        Plug 'neovim/nvim-lspconfig', { 'tag': 'v2.3.0'}

        " Search engine
        Plug 'nvim-telescope/telescope.nvim', { 'tag': 'v0.2.1' }

      else
        """"""""""""""""""""
        " v0.9.0 ~ v0.10.4 "
        """"""""""""""""""""
        if has('nvim-0.9.0')
          " Highlighting support
          Plug 'nvim-treesitter/nvim-treesitter', { 'tag': 'v0.9.0' }
          
          " Language Server Protocols
          Plug 'neovim/nvim-lspconfig', { 'tag': 'v1.8.0'}

          " Search engine
          Plug 'nvim-telescope/telescope.nvim', { 'tag': 'v0.1.9' }

          """""""""""""""""""
          " v0.7.0 ~ v0.9.0 "
          """""""""""""""""""
          if has('nvim-0.7.0')
            " Highlighting support
            Plug 'nvim-treesitter/nvim-treesitter', { 'tag': 'v0.7.2' }

            " Language Server Protocols
            Plug 'neovim/nvim-lspconfig', { 'tag': 'v0.1.6'}
            
            " Search engine
            Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
      
          """"""""""""""""""""
          " v0.6.0 ~ v0.7.0  "
          """"""""""""""""""""
          elseif has('nvim-0.6.0')
            Plug 'neovim/nvim-lspconfig', { 'tag': 'v0.1.3'}

          endif 
        endif
      endif

      """"""""""""""""""""
      " v0.9.0 ~ v0.11.0 "
      """"""""""""""""""""
      if has('nvim-0.9.0')
        " Manager installer
        Plug 'williamboman/mason-lspconfig.nvim', { 'tag': 'v1.32.0' }

      """"""""""""""""""""
      " v0.7.0 ~ v0.9.0  "
      """"""""""""""""""""
      elseif has('nvim-0.7.0')
        " Manager installer
        Plug 'williamboman/mason-lspconfig.nvim', { 'tag': 'v1.6.0' }

      endif 

      """"""""""""""""""""
      " v0.7.0 ~ v0.11.0 "
      """"""""""""""""""""
      if has('nvim-0.7.0')
        Plug 'nvim-neo-tree/neo-tree.nvim', { 'tag': 'v2.71' }


      endif
    endif

    """"""""""""""""""""""
    " NeoVim    v0.10.4+ "
    """"""""""""""""""""""
    if has('nvim-0.10.4')
      " Manager installer
      Plug 'williamboman/mason.nvim'

      """"""""""""""""""""
      " v0.7.0 ~ v0.10.4 "
      """"""""""""""""""""
    elseif has('nvim-0.7.0')
      " Manager installer
      Plug 'williamboman/mason.nvim', { 'tag': 'v1.11.0' }
    endif

    """""""""""""""""""""
    " NeoVim    v0.8.0+ "
    """""""""""""""""""""
    if has('nvim-0.8.0')
      " Utils
      Plug 'nvim-lua/plenary.nvim'

      " Autocompletion
      Plug 'hrsh7th/nvim-cmp'  "Autocompletion plugin

      """"""""""""""""""""
      " v0.7.0 ~ v0.8.0 "
      """"""""""""""""""""
    elseif has('nvim-0.7.0')
        " Autocompletion
        Plug 'hrsh7th/nvim-cmp', { 'tag': 'v0.0.1' } 

    endif
      
    """""""""""""""""""""
    " NeoVim    v0.7.0+ "
    """""""""""""""""""""
    if has('nvim-0.7.0')
      Plug 'L3MON4D3/LuaSnip', { 'branch': 'master' }
      """"""""""""""""""""
      " v0.5.0 ~ v0.7.0 "
      """"""""""""""""""""
    elseif has('nvim-0.5')
      Plug 'L3MON4D3/LuaSnip', { 'tag': 'v1.2.1' }

      " Manager installer
      Plug 'MordechaiHadad/nvim-lspmanager'

    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " === ===== ===   CONFLICT PLUGIN VERSIONS   === ===== === "
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  else
    " Tree
    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

  	" Pairing
    Plug 'jiangmiao/auto-pairs'

    " Completion
    " Use release branch (recommend)
    Plug 'neoclide/coc.nvim', { 'branch': 'release'}
  endif

call plug#end()

