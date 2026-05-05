--                      ---
-- LSP - configurations ---
--                      ---
local lsp_server_settings = {
  vimls = {
    init_options = {
      diagnostic = {
        enable = true,
      },
      indexes = {
        count = 3,
        gap = 100,
        projectRootPatterns = { "runtime", "nvim", ".git", "autoload", "plugin" },
        runtimepath = true,
      },
      isNeovim = true,
      iskeyword = "@,48-57,_,192-255,-#",
      runtimepath = "",
      suggest = {
        fromRuntimepath = true,
        fromVimruntime = true,
      },
      vimruntime = "",
    },
  },
  lua_ls = {
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
          globals = { "vim" },
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
  biome = {
    cmd = { "biome", "lsp-proxy" },
    filetypes = {
      "astro",
      --"css",
      "graphql",
      --"javascript",
      "javascriptreact",
      "json",
      "jsonc",
      "svelte",
      --"typescript",
      "typescript.tsx",
      "typescriptreact",
      "vue",
    },
    -- root_dir = function(fname)
    --   local root_files = { 'biome.json', 'biome.jsonc' }
    --   root_files = util.insert_package_json(root_files, 'biome', fname)
    --   return vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1])
    -- end,
    single_file_support = false,
  },
}

lsp_server_settings.sumneko_lua = lsp_server_settings.lua_ls
lsp_server_settings.tsserver = lsp_server_settings.ts_ls

--                          ---
-- Protocol Completion List ---
--                          ---
local protocol_completion_item = {
  "", -- Text
  "", -- Method
  "", -- Function
  "", -- Constructor
  "", -- Field
  "", -- Variable
  "", -- Class
  "ﰮ", -- Interface
  "", -- Module
  "", -- Property
  "", -- Unit
  "", -- Value
  "", -- Enum
  "", -- Keyword
  "﬌", -- Snippet
  "", -- Color
  "", -- File
  "", -- Reference
  "", -- Folder
  "", -- EnumMember
  "", -- Constant
  "", -- Struct
  "", -- Event
  "ﬦ", -- Operator
  "", -- TypeParameter
}


return { servers = lsp_server_settings, protocol = protocol_completion_item }
