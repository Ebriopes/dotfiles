--[[require('lint').linters_by_ft = {
  markdown = {'vale',}
}]]

if vim.fn.has('nvim-0.7.0') == 1 then
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      require("lint").try_lint()
    end,
  })
end
