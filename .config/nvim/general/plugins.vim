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
  "Plug 'nvim-neo-tree/neo-tree.nvim'
    "Plug 'nvim-lua/plenary.nvim'
    "Plug 'kyazdani42/nvim-web-devicons' " not strictly required, but recommended
    "Plug 'MunifTanjim/nui.nvim'

  " Commenter
  Plug 'preservim/nerdcommenter'

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
    " Tree
    Plug 'kevinhwang91/rnvimr'
    
    " Notifications
    Plug 'rcarriga/nvim-notify', { 'on': [] }

    " Icons
    Plug 'kyazdani42/nvim-web-devicons'

    " RipGrep
    Plug 'duane9/nvim-rg'

    " Language Server Protocols
    Plug 'neovim/nvim-lspconfig', { 'tag': 'v0.1.3'}

    if has('nvim-0.3.1')
      Plug 'dstein64/vim-startuptime'

    if has('nvim-0.5')
      Plug 'L3MON4D3/LuaSnip'

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
      Plug 'nvim-treesitter/nvim-treesitter' ", {'do': ':TSUpdate'}

    endif

    if has('nvim-0.9.0')
      " Search engine
      Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0', 'on': [] }
      Plug 'nvim-lua/plenary.nvim', { 'on': [] }
        Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make', 'on': [] }

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
