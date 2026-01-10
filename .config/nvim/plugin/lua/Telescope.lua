local ok, telescope = pcall(require, 'telescope')
local utils = require("utils")

if not ok then
  return
end

telescope.setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        --["<C-h>"] = "which_key"
      }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}


local function search_config()
  require('telescope.builtin').find_files({
    cwd = vim.fn.stdpath('config'), -- Esto apunta a AppData/Local/nvim en Windows
    prompt_title = ' Configuración de NeoVim ',
  })
end

utils.search_config = search_config

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Find files using Telescope command-line sugar.
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts)
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts)
keymap("n", "<leader>fs", "<cmd>Telescope lsp_workspace_symbols<cr>", opts)
keymap("n", "<leader>fsw", "<cmd>Telescope lsp_workspace_symbols<cr>", opts)
keymap("n", "<leader>fsd", "<cmd>Telescope lsp_document_symbols<cr>", opts)
-- Ver registros (yank history) en una ventana flotante con Telescope
keymap('n', '<leader>fr', '<cmd>Telescope registers<cr>', vim.tbl_extend( "force", opts, { desc = '[User]{Telescope} Ver Registros (Yank History)' }))
keymap('n', '<leader>fc', search_config, vim.tbl_extend('force', opts, { desc = '[User]{Telescope} Buscar en Configuración de Neovim' }))

