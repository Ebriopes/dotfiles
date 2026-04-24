local is_installed, snacks = pcall(require, "snacks")

if not is_installed then
  return
end

snacks.setup({
  input = {}, -- enhances `ask()` [opencode]
  picker = {  -- Mejora select() [opencode]
    actions = {
      opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
    },
    win = {
      input = {
        keys = {
          ["<C-s>"] = { "opencode_send", mode = { "n", "i" } }, -- Asigna una tecla, ej: Ctrl+s
        },
      },
    },
  },
  dashboard = {
    enabled = true,
    sections = {
      { section = "header" },
      { section = "keys",  gap = 1, padding = 1 },
      --{ section = "startup" }
      ---- Sección personalizada para tus proyectos de Frontend
      --{
      --section = "terminal",
      --cmd = "pokemon-colorscripts -r --no-title", -- Opcional: si tienes esto en tu terminal
      --random = 10,
      --pane = 2,
      --indent = 4,
      --height = 30,
      --},
    },
    -- Mapeos para el dashboard
    --preset = {
      --keys = {
        --{ icon = " ", key = "f", desc = "Buscar Archivo", action = ":Telescope find_files" },
        --{ icon = " ", key = "n", desc = "Nuevo Archivo", action = ":ene | startinsert" },
        --{ icon = "󰒲 ", key = "m", desc = "Mason", action = ":Mason" },
        --{
          --icon = "xml ",
          --key = "c",
          --desc = "Configuración",
          --action = ":lua require('utils').search_config()",
        --}, -- Tu nuevo buscador
        --{ icon = " ", key = "g", desc = "Git Status", action = ":Telescope git_status" },
        --{ icon = " ", key = "q", desc = "Salir", action = ":qa" },
      --},
    --},
  },
})
