local ok, lspmanager = pcall(require, 'nvim-lspmanager') 

if not ok then
  return
end

lspmanager.setup({
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
})
