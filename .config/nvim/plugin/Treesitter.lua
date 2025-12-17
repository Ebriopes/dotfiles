local ok,treesitter_conf = pcall(require, 'nvim-treesitter.configs')

if not ok then
  return
end

treesitter_conf.setup {
  -- A list of parser names, or "all"
  ensure_installed = {
    "bash",
    "css",
    "gdscript",
    "graphql",
    "html",
    "http",
    "javascript",
    "latex",
    "lua",
    "markdown",
    "perl",
    "python",
    "scss",
    "solidity",
    "sql",
    "typescript",
    "vim"
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = true,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    --disable = { "c", "rust" },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = { 'lua' },
  },
}

vim.opt.foldmethod = 'expr'

-- For Neovim v0.10.0+ it's recommended to use the core function
if vim.fn.has('nvim-0.10.0') then
  vim.opt.foldexpr = "vim.treesitter.foldexpr()"
else
  vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
  --vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  --vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  --vim.wo.foldmethod = 'expr'
end

vim.opt.foldlevelstart = 5 -- Puedes mantener esto
vim.opt.foldcolumn = '1'     -- Puedes mantener esto

let g:javaScript_fold = 1

