return {
  {
    "preservim/vim-pencil",
    ft = { "text", "markdown", "rst", "asciidoc" },
    config = function()
      vim.cmd("PencilSoft")
    end,
  },
}

