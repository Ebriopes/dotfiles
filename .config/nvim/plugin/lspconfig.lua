-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local lsp_ok, lspconfig = pcall(require, 'lspconfig')

if not lsp_ok then
  return
end

local lsp_buf = vim.lsp.buf
local protocol = require 'vim.lsp.protocol'

local opts = { noremap = true, silent = true }

if vim.fn.has('nvim-0.7.0') == 1 then
  local keymap = vim.keymap.set

  keymap('n', '<space>e', vim.diagnostic.open_float, opts)
  keymap('n', '[d', vim.diagnostic.goto_prev, opts)
  keymap('n', ']d', vim.diagnostic.goto_next, opts)
  keymap('n', '<space>q', vim.diagnostic.setloclist, opts)

else
  local keymap = vim.api.nvim_set_keymap

  keymap('n', '<space>e', 'vim.diagnostic.open_float', opts)
  keymap('n', '[d', 'vim.diagnostic.goto_prev', opts)
  keymap('n', ']d', 'vim.diagnostic.goto_next', opts)
  keymap('n', '<space>q', 'vim.diagnostic.setloclist', opts)

end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  --vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  if vim.fn.has('nvim-0.7.0') == 1 then
    local keymap = vim.keymap.set

    keymap('n', 'gD', lsp_buf.declaration, bufopts)
    --keymap('n', 'gd', lsp_buf.definition, bufopts)
    --keymap('n', 'K', lsp_buf.hover, bufopts)
    keymap('n', 'gi', lsp_buf.implementation, bufopts)
    keymap('n', '<C-k>', lsp_buf.signature_help, bufopts)
    keymap('n', '<space>wa', lsp_buf.add_workspace_folder, bufopts)
    keymap('n', '<space>wr', lsp_buf.remove_workspace_folder, bufopts)
    keymap('n', '<space>wl', function()
      print(vim.inspect(lsp_buf.list_workspace_folders()))
    end, bufopts)
    keymap('n', '<space>D', lsp_buf.type_definition, bufopts)
    keymap('n', '<space>rn', lsp_buf.rename, bufopts)
    keymap('n', '<space>ca', lsp_buf.code_action, bufopts)
    --keymap('n', 'gr', lsp_buf.references, bufopts)
    keymap('n', '<space>f', lsp_buf.formatting, bufopts)
  else
    local keymap = vim.api.nvim_buf_set_keymap

    keymap(bufnr, 'n', 'gD', 'lsp_buf.declaration', bufopts)
    --keymap(bufnr, 'n', 'gd', 'lsp_buf.definition', bufopts)
    --keymap(bufnr, 'n', 'K', 'lsp_buf.hover', bufopts)
    keymap(bufnr, 'n', 'gi', 'lsp_buf.implementation', bufopts)
    keymap(bufnr, 'n', '<C-k>', 'lsp_buf.signature_help', bufopts)
    keymap(bufnr, 'n', '<space>wa', 'lsp_buf.add_workspace_folder', bufopts)
    keymap(bufnr, 'n', '<space>wr', 'lsp_buf.remove_workspace_folder', bufopts)
    keymap(bufnr, 'n', '<space>wl', 'function() print(vim.inspect(lsp_buf.list_workspace_folders())) end', bufopts)
    keymap(bufnr, 'n', '<space>D', 'lsp_buf.type_definition', bufopts)
    keymap(bufnr, 'n', '<space>rn', 'lsp_buf.rename', bufopts)
    keymap(bufnr, 'n', '<space>ca', 'lsp_buf.code_action', bufopts)
    --keymap(bufnr, 'n', 'gr', 'lsp_buf.references', bufopts)
    keymap(bufnr, 'n', '<space>f', 'lsp_buf.formatting', bufopts)
  end

  protocol.CompletionItemKind = {
      '', -- Text
      '', -- Method
      '', -- Function
      '', -- Constructor
      '', -- Field
      '', -- Variable
      '', -- Class
      'ﰮ', -- Interface
      '', -- Module
      '', -- Property
      '', -- Unit
      '', -- Value
      '', -- Enum
      '', -- Keyword
      '﬌', -- Snippet
      '', -- Color
      '', -- File
      '', -- Reference
      '', -- Folder
      '', -- EnumMember
      '', -- Constant
      '', -- Struct
      '', -- Event
      'ﬦ', -- Operator
      '', -- TypeParameter
    }
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

-- Add additional capabilities supported by nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')

if ok then
  capabilities = cmp_lsp.update_capabilities(capabilities)
end

local lang_settings = {
  vimls = {
    init_options = {
      diagnostic = {
        enable = true
      },
      indexes = {
        count = 3,
        gap = 100,
        projectRootPatterns = { "runtime", "nvim", ".git", "autoload", "plugin" },
        runtimepath = true
      },
      isNeovim = true,
      iskeyword = "@,48-57,_,192-255,-#",
      runtimepath = "",
      suggest = {
        fromRuntimepath = true,
        fromVimruntime = true
      },
      vimruntime = ""
    }
  },
  sumneko_lua = {
    settings = {
      Lua = {
        --[[
        runtime = {
          -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
        },
      ]]
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { 'vim' },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  },
  diagnosticls = {
    filetypes = { 'javascript', 'javascriptreact', 'json', 'typescript', 'typescriptreact', 'css', 'less', 'scss',
      'markdown', 'pandoc' },
    init_options = {
      linters = {
        eslint = {
          command = 'eslint_d',
          rootPatterns = { '.git' },
          debounce = 100,
          args = { '--stdin', '--stdin-filename', '%filepath', '--format', 'json' },
          sourceName = 'eslint_d',
          parseJson = {
            errorsRoot = '[0].messages',
            line = 'line',
            column = 'column',
            endLine = 'endLine',
            endColumn = 'endColumn',
            message = '[eslint] ${message} [${ruleId}]',
            security = 'severity'
          },
          securities = {
            [2] = 'error',
            [1] = 'warning'
          }
        },
      },
      filetypes = {
        javascript = 'eslint',
        javascriptreact = 'eslint',
        typescript = 'eslint',
        typescriptreact = 'eslint',
      },
      formatters = {
        eslint_d = {
          command = 'eslint_d',
          args = { '--stdin', '--stdin-filename', '%filename', '--fix-to-stdout' },
          rootPatterns = { '.git' },
        },
        prettier = {
          command = 'prettier',
          args = { '--stdin-filepath', '%filename' }
        }
      },
      formatFiletypes = {
        css = 'prettier',
        javascript = 'eslint_d',
        javascriptreact = 'eslint_d',
        json = 'prettier',
        scss = 'prettier',
        less = 'prettier',
        typescript = 'eslint_d',
        typescriptreact = 'eslint_d',
        markdown = 'prettier',
      }
    }
  }
}

--local servers = { 'pyright', 'vimls', 'sumneko_lua', 'tsserver', 'diagnosticls', "angularls", 'bashls', 'cssls', 'eslint',
--'gdscript', 'graphql', 'html', 'jsonls', 'sqlls' }
local servers = { 'pyright', 'vimls', 'sumneko_lua', 'tsserver', 'angularls', 'bashls', 'cssls', 'jsonls', 'graphql', 'html' }

for _, lsp in ipairs(servers) do
  local config = {
    on_attach = on_attach,
    flags = lsp_flags,
  }

  if capabilities then
    config.capabilities = capabilities
  end

  if lang_settings[lsp] then
    if lang_settings[lsp].filetypes then
      config.filetypes = lang_settings[lsp].filetypes
    end
    if lang_settings[lsp].settings then
      config.settings = lang_settings[lsp].settings
    end
    if lang_settings[lsp].init_options then
      config.init_options = lang_settings[lsp].init_options
    end
  end

  lspconfig[lsp].setup(config)
end

-- icon
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  signs = true,
  severity_sort = true,
  virtual_text = {
    spacing = 4,
    prefix = ''
  },
  float = {
    source = 'always',
    border = 'rounded'
  }
}
)

local notify = require('notify')

vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local lvl = ({ 'ERROR', 'WARN', 'INFO', 'DEBUG' })[result.type]

  notify(result.message, lvl, {
    title = 'LSP | ' .. client.name,
    timeout = 10000,
    keep = function()
      return lvl == 'ERROR' or lvl == 'WARN'
    end
  })
end
