--            ---
-- Variables  ---
--            ---
local lsp_buf = vim.lsp.buf
local lsp_flags = { debounce_text_changes = 150 } -- This is the default in Nvim 0.7+
local opts = { noremap = true, silent = true }
local protocol = require("vim.lsp.protocol")
local lsp_settings = require('lsp-settings')

--                ---
-- LSP - servers  ---
--                ---
local servers = {
  "pyright",
  "vimls",
  "angularls",
  "bashls",
  "cssls",
  "jsonls",
  "graphql",
  "html",
  "lemminx",
}

if vim.fn.has('nvim-0.8.0') == 1 then
  vim.list_extend(servers, { "lua_ls", "ts_ls", "biome" })
else
  vim.list_extend(servers, { 'sumneko_lua', 'tsserver' })
end

--                                      ---
-- LSP - Key mapping - On attach buffer ---
--                                      ---
local on_attach = function(client, bufnr)
  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer

  -- Enable completion triggered by <c-x><c-o>
  --vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  if vim.fn.has("nvim-0.7.0") == 1 then
    local keymap = vim.keymap.set

    keymap("n", "gD", lsp_buf.declaration, bufopts)
    --keymap('n', 'gd', lsp_buf.definition, bufopts)
    --keymap('n', 'K', lsp_buf.hover, bufopts)
    keymap("n", "gi", lsp_buf.implementation, bufopts)
    keymap("n", "<C-k>", lsp_buf.signature_help, bufopts)
    keymap("n", "<space>wa", lsp_buf.add_workspace_folder, bufopts)
    keymap("n", "<space>wr", lsp_buf.remove_workspace_folder, bufopts)
    keymap("n", "<space>wl", function()
      print(vim.inspect(lsp_buf.list_workspace_folders()))
    end, bufopts)
    keymap("n", "<space>D", lsp_buf.type_definition, bufopts)
    keymap("n", "<space>rn", lsp_buf.rename, bufopts)
    keymap("n", "<space>ca", lsp_buf.code_action, bufopts)
    --keymap('n', 'gr', lsp_buf.references, bufopts)

    if vim.fn.has("nvim-0.7.0") then
      keymap("n", "<space>f", lsp_buf.formatting, bufopts)
    else
      keymap("n", "<space>f", lsp_buf.format, bufopts)
    end
  else
    local keymap = vim.api.nvim_buf_set_keymap

    keymap(bufnr, "n", "gD", "lsp_buf.declaration", bufopts)
    --keymap(bufnr, 'n', 'gd', 'lsp_buf.definition', bufopts)
    --keymap(bufnr, 'n', 'K', 'lsp_buf.hover', bufopts)
    keymap(bufnr, "n", "gi", "lsp_buf.implementation", bufopts)
    keymap(bufnr, "n", "<C-k>", "lsp_buf.signature_help", bufopts)
    keymap(bufnr, "n", "<space>wa", "lsp_buf.add_workspace_folder", bufopts)
    keymap(bufnr, "n", "<space>wr", "lsp_buf.remove_workspace_folder", bufopts)
    keymap(bufnr, "n", "<space>wl", "function() print(vim.inspect(lsp_buf.list_workspace_folders())) end", bufopts)
    keymap(bufnr, "n", "<space>D", "lsp_buf.type_definition", bufopts)
    keymap(bufnr, "n", "<space>rn", "lsp_buf.rename", bufopts)
    keymap(bufnr, "n", "<space>ca", "lsp_buf.code_action", bufopts)
    --keymap(bufnr, 'n', 'gr', 'lsp_buf.references', bufopts)
    --keymap(bufnr, 'n', '<space>f', lsp_buf.formatting, bufopts)
  end

  --if client.resolved_capabilities.document_formatting then
  --vim.api.nvim_command [[autogroup Format]]
  --vim.api.nvim_command [[autocmd! * <buffer>]]
  --vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]]
  --vim.api.nvim_command [[autogroup END]]
  --end

  protocol.CompletionItemKind = lsp_settings.protocol
end

--
-- Key mapping - Diagnostics -----------------------------------
if vim.fn.has("nvim") then
  if vim.fn.has("nvim-0.7.0") == 0 then
    -- Keymaps to old Neovim versions --
    -- before of version 0.7
    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    local keymap = vim.api.nvim_set_keymap

    keymap("n", "<space>e", "vim.diagnostic.open_float", opts)
    keymap("n", "[d", "vim.diagnostic.goto_prev", opts)
    keymap("n", "]d", "vim.diagnostic.goto_next", opts)
    keymap("n", "<space>q", "vim.diagnostic.setloclist", opts)
  else
    local keymap = vim.keymap.set
    local diagnostics = vim.diagnostic

    keymap("n", "<space>q", diagnostics.setloclist, opts)
    keymap("n", "<space>e", diagnostics.open_float, opts)

    if vim.fn.has("nvim-0.11.0") == 0 then
      -- Keymaps to use until NVIM 0.10 --
      keymap("n", "[d", diagnostics.goto_prev, opts)
      keymap("n", "]d", diagnostics.goto_next, opts)
    else
      -- Keymaps to use with NVIM 0.11+
      local jump = diagnostics.jump

      keymap("n", "[d", function()
        jump({ count = -1, float = true })
      end, opts)

      keymap("n", "]d", function()
        jump({ count = 1, float = true })
      end, opts)
    end
  end
end

-- Check the plugin availability
if vim.fn.has("nvim-0.11.0") == 0 then
  local lsp_ok = pcall(require, "lspconfig")

  if not lsp_ok then
    return
  end
end

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
-- Update capabilities
if ok then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Setup every LSP config
for _, lsp in ipairs(servers) do
  local config = {
    on_attach = on_attach,
    flags = lsp_flags,
  }

  if capabilities then
    config.capabilities = capabilities
  end

  if lsp_settings.servers[lsp] then
    for config_field, config_settings in pairs(lsp_settings.servers[lsp]) do
      config[config_field] = config_settings
    end
  end

  if vim.fn.has("nvim-0.11.0") == 1 then
    vim.lsp.config(lsp, config)
  else
    require("lspconfig")[lsp].setup(config)
  end
end

--
-- Icon
--[[
   [vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
   [  underline = true,
   [  signs = true,
   [  severity_sort = true,
   [  virtual_text = {
   [    spacing = 4,
   [    prefix = "",
   [  },
   [  float = {
   [    source = "always",
   [    border = "rounded",
   [  },
   [})
   ]]
