local is_installed, mini = pcall(require, "mini.pairs")

if not is_installed then
  return
end

mini.setup({
  -- In which modes mappings from this `config` should be created
  modes = { insert = true, command = false, terminal = false },

  -- Global mappings. Each right hand side should be a pair information, a
  -- table with at least these fields (see more in |MiniPairs.map|):
  -- - <action> - one of 'open', 'close', 'closeopen'.
  -- - <pair> - two character string for pair to be used.
  -- By default pair is not inserted after `\`, quotes are not recognized by
  -- <CR>, `'` does not insert the pair after a letter.
  -- Only parts of tables can be tweaked (others will use these defaults).
  mappings = {
    ['('] = { action = 'open', pair = '()', neigh_pattern = '^[^\\]' },
    ['['] = { action = 'open', pair = '[]', neigh_pattern = '^[^\\]' },
    ['{'] = { action = 'open', pair = '{}', neigh_pattern = '^[^\\]' },

    [')'] = { action = 'close', pair = '()', neigh_pattern = '^[^\\]' },
    [']'] = { action = 'close', pair = '[]', neigh_pattern = '^[^\\]' },
    ['}'] = { action = 'close', pair = '{}', neigh_pattern = '^[^\\]' },

    ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '^[^\\]',   register = { cr = false } },
    ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '^[^%a\\]', register = { cr = false } },
    ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '^[^\\]',   register = { cr = false } },
  },
})


if vim.fn.has("nvim-0.10.0") == 1 then
  -- Forzar el comportamiento de Enter para que sea inteligente
  local keymap = vim.keymap.set
  local function cr_action()
    if vim.fn.pumvisible() ~= 0 then
      -- Si el menú de autocompletado (cmp) está abierto, confirma la selección
      return vim.api.nvim_replace_termcodes('<C-y>', true, true, true)
    else
      -- Si no, deja que mini.pairs maneje el Enter
      return require('mini.pairs').cr()
    end
  end

  keymap('i', '<CR>', cr_action, { expr = true, replace_keycodes = false })
end
