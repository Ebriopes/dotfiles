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
  Plug 'jiangmiao/auto-pairs'
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
    if has('unix')
      Plug 'kevinhwang91/rnvimr'
    endif
    
    " Notifications
    Plug 'rcarriga/nvim-notify', { 'tag': 'v3.14.1'}

    " Icons
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'nvim-mini/mini.nvim'

    " RipGrep
    Plug 'duane9/nvim-rg'

    if has('nvim-0.3.1')
      Plug 'dstein64/vim-startuptime'
    endif

    if has('nvim-0.5')
      Plug 'L3MON4D3/LuaSnip', { 'tag': 'v1.2.1' }

      " Utils
      Plug 'MunifTanjim/nui.nvim'

      if !has('nvim-0.7.0')
        " Manager installer
        Plug 'MordechaiHadad/nvim-lspmanager'
      endif
    endif

    if has('nvim-0.6.0')
      " Linter
      Plug 'mfussenegger/nvim-lint'

      " Language Server Protocols
      Plug 'neovim/nvim-lspconfig', { 'tag': 'v0.1.3'}
      Plug 'antosha417/nvim-lsp-file-operations'

    endif
    
    if has('nvim-0.7.0')
      "Plug 'L3MON4D3/LuaSnip', { 'branch': 'master' }
      Plug 'L3MON4D3/LuaSnip', { 'tag': 'v1.2.1' }

      " Manager installer
      Plug 'williamboman/mason.nvim', { 'tag': 'v1.11.0' }
      Plug 'williamboman/mason-lspconfig.nvim', { 'tag': 'v1.6.0' }

      " Autocompletion
      Plug 'hrsh7th/nvim-cmp', { 'tag': 'v0.0.1' }  "Autocompletion plugin

      " Language Server Protocols
      Plug 'hrsh7th/cmp-nvim-lsp' "LSP source for nvim-cmp
      Plug 'neovim/nvim-lspconfig', { 'tag': 'v0.1.6'}
      "Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }

      " For luasnip users.
      Plug 'saadparwaiz1/cmp_luasnip'

      " Highlighting support
      Plug 'nvim-treesitter/nvim-treesitter', { 'tag': 'v0.7.2' } ", {'do': ':TSUpdate'}

      Plug 'nvim-neo-tree/neo-tree.nvim', { 'tag': 'v2.71' }
      " Search engine
      Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
        Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
    endif

    if has('nvim.0.8.0')
      " Utils
      Plug 'nvim-lua/plenary.nvim'

      " Autocompletion
      Plug 'hrsh7th/nvim-cmp'  "Autocompletion plugin
    endif

    if has('nvim-0.9.0')
      Plug 'nvim-treesitter/nvim-treesitter', { 'tag': 'v0.9.0' } ", {'do': ':TSUpdate'}

      " Language Server Protocols
      Plug 'neovim/nvim-lspconfig', { 'tag': 'v1.8.0'}
      Plug 'nvimdev/lspsaga.nvim'

      " Manager installer
      Plug 'williamboman/mason-lspconfig.nvim', { 'tag': 'v1.32.0' }

      " Search engine
      Plug 'nvim-telescope/telescope.nvim', { 'tag': 'v0.1.9' }

        if has('nvim-0.9.4')
          " Utils
          Plug 'folke/snacks.nvim'
        endif
    endif

    if has('nvim-0.10.4')
      Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'master' } ", {'do': ':TSUpdate'}

      " Language Server Protocols
      Plug 'neovim/nvim-lspconfig', { 'tag': 'v2.3.0'}

      " Manager installer
      Plug 'williamboman/mason.nvim'

      " Search engine
      Plug 'nvim-telescope/telescope.nvim', { 'tag': 'v0.2.1' }
      
      " Notifications
      Plug 'rcarriga/nvim-notify'
    endif

    if has('nvim-0.11.0')
      Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'main' } ", {'do': ':TSUpdate'}

      " Language Server Protocols
      Plug 'neovim/nvim-lspconfig', { 'branch': 'master'}

      " Manager installer
      Plug 'williamboman/mason-lspconfig.nvim'
    endif

  else
    " Tree
    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

    " Completion
    " Use release branch (recommend)
    Plug 'neoclide/coc.nvim', { 'branch': 'release'}
  endif

call plug#end()

let g:plug_window = 'botright new'
