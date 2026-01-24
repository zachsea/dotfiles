-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.api.nvim_create_autocmd("User", {
  pattern = "TSUpdate",
  callback = function()
    require("nvim-treesitter.parsers").ca65 = {
      install_info = {
        url = "https://github.com/zachsea/tree-sitter-ca65",
        queries = "queries/ca65",
      },
    }
  end,
})

vim.treesitter.language.register("ca65", { "asm" })
