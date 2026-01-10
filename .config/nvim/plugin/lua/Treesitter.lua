local is_installed, treesitter = pcall(require, "nvim-treesitter")
local has_configs, treesitter_configs = pcall(require, "nvim-treesitter.configs")

if not is_installed then
	print("Error cargando configuración de Treesitter...") -- Línea de diagnóstico
	return
end

-- Fold settings --
vim.opt.foldmethod = "expr"
vim.opt.foldlevelstart = 5 -- Puedes mantener esto
vim.opt.foldcolumn = "1" -- Puedes mantener esto

if vim.fn.has("nvim-0.10.0") == 1 then
	-- For Neovim v0.10.0+ it's recommended to use the core function
	vim.opt.foldexpr = "vim.treesitter.foldexpr()"

	if vim.fn.has("nvim-0.11.0") == 1 then
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo.foldmethod = "expr"
	end
else
	vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
	--vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
end

-- Forzar Treesitter folding y evitar que otros plugins lo reseteen
--[[
   [vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
   [  pattern = { "html", "javascript", "typescript", "lua" },
   [  callback = function()
   [    -- Esperar un poco a que el LSP y Parsers carguen
   [    vim.schedule(function()
   [      vim.opt_local.foldmethod = "expr"
   [
   [      if vim.fn.has("nvim-0.10.0") == 1 then
   [        vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
   [      else
   [        vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
   [      end
   [      -- Mantener el archivo abierto al inicio
   [      vim.opt_local.foldlevel = 99
   [    end)
   [  end,
   [})
   ]]

-- Specific version configuration -----

-- Check if it's using old version
if not has_configs then
	treesitter.install({
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
		"vim",
	})
else
	treesitter_configs.setup({
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
			"vim",
		},

		-- Install parsers synchronously (only applied to `ensure_installed`)
		sync_install = true,

		-- Automatically install missing parsers when entering buffer
		auto_install = true,

		-- List of parsers to ignore installing (for "all")
		ignore_install = {},

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
			additional_vim_regex_highlighting = { "lua" },
		},
	})
end
