local ok, notify = pcall(require, "notify")

if not ok then
  return
end


-- Default config
notify.setup({
  background_colour = "NotifyBackground",
  fps = 30,
  icons = {
    DEBUG = "",
    ERROR = "",
    INFO = "",
    TRACE = "✎",
    WARN = "",
  },
  level = 2,
  minimum_width = 50,
  render = "default",
  stages = "fade_in_slide_out",
  time_formats = {
    notification = "%T",
    notification_history = "%FT%T",
  },
  timeout = 5000,
  top_down = true,
})

-- Activate 24bit terminal colors
vim.opt.termguicolors = true
-- Set global notification function
vim.notify = notify

-- Setup LSP notifications
vim.lsp.handlers["window/showMessage"] = function(_, result, ctx)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  local lvl = ({ "ERROR", "WARN", "INFO", "DEBUG" })[result.type]
  local options = {
    title = "LSP | " .. client.name,
    timeout = 10000,
    keep = function()
      return lvl == "ERROR" or lvl == "WARN"
    end,
  }

  notify(result.message, lvl, options)
end
