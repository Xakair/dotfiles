-- ~/.config/nvim/lua/plugins/writing_centered.lua
return {
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        width = 80, -- or your preferred text width
        options = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
        },
      },
    },
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle Zen Mode" },
    },
    cmd = "ZenMode",
  },
}

