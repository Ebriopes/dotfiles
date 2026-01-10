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

  " Utils
  Plug 'nvim-lua/plenary.nvim'

  """ Extras
  " Battery
  "Plug 'lambdalisue/battery.vim'
  
  " Narrowing
  Plug 'chrisbra/NrrwRgn'

  " Float terminal
  Plug 'voldikss/vim-floaterm', { 'on': [] }

  if has('nvim')
    " Tree
    "Plug 'preservim/nerdtree'
    if has('unix')
      Plug 'kevinhwang91/rnvimr'
    endif
    
    " Notifications
    Plug 'rcarriga/nvim-notify'

    " Icons
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'nvim-mini/mini.nvim'

    " RipGrep
    Plug 'duane9/nvim-rg'

    " Language Server Protocols
    Plug 'neovim/nvim-lspconfig', { 'tag': 'v0.1.3'}
    Plug 'antosha417/nvim-lsp-file-operations'

    if has('nvim-0.3.1')
      Plug 'dstein64/vim-startuptime'

      if has('nvim-0.5')
        Plug 'L3MON4D3/LuaSnip'

        " Utils
        Plug 'MunifTanjim/nui.nvim'

        if !has('nvim-0.7.0')
          " Manager installer
          Plug 'MordechaiHadad/nvim-lspmanager'
        endif
      endif
    endif

    if has('nvim-0.6.0')
      " Linter
      Plug 'mfussenegger/nvim-lint'
    endif
    
    if has('nvim-0.7.0')
      " Manager installer
      Plug 'williamboman/mason.nvim'
      Plug 'williamboman/mason-lspconfig.nvim'

      " Autocompletion
      Plug 'hrsh7th/nvim-cmp'  "Autocompletion plugin

      " Language Server Protocols
      Plug 'hrsh7th/cmp-nvim-lsp' "LSP source for nvim-cmp
      Plug 'neovim/nvim-lspconfig', { 'branch': 'master'}
      Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }

      " For luasnip users.
      Plug 'saadparwaiz1/cmp_luasnip'

      " Highlighting support
      Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'master' } ", {'do': ':TSUpdate'}

    endif

    if has('nvim-0.9.0')
      " Search engine
      Plug 'nvim-telescope/telescope.nvim', { 'tag': 'v0.1.9' }
        Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

        if has('nvim-0.9.4')
          " Utils
          Plug 'folke/snacks.nvim'
        endif
    endif

    if has('nvim-0.10.4')
      " Search engine
      Plug 'nvim-telescope/telescope.nvim', { 'tag': 'v0.2.0' }
    endif

    if has('nvim-0.11.0')
      Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'main' } ", {'do': ':TSUpdate'}
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
