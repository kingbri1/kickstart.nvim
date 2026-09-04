vim.pack.add({
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-lualine/lualine.nvim",
})

require("lualine").setup({
    sections = {
        lualine_x = {
            'encoding',
            {
                'fileformat',
                symbols = {
                    unix = 'unix',
                    dos = 'dos',
                    mac = 'mac',
                },
            },
            'filetype',
        },
    },
    options = {
        section_separators = { left = '', right = '' },
        component_separators = ''
    },
})
