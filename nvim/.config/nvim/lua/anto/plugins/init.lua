-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'glacambre/firenvim',
    cond = not not vim.g.started_by_firenvim,
    build = function()
      require("lazy").load({ plugins = { "firenvim" }, wait = true })
      vim.fn["firenvim#install"](0)
    end,

    -- configure FireNvim here:
    config = function()
      vim.g.firenvim_config = {
        -- config values, like in my case:
        localSettings = {
          [".*"] = {
            takeover = "never",
          },
        },
      }
      -- vim.cmd.colorscheme('catppuccin-latte')
    end
  },
}
