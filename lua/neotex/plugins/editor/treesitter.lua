return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",

    config = function()
      local treesitter = require("nvim-treesitter")

      -- nvim-treesitter `main` installs parsers and queries here by
      -- default. Defining it explicitly keeps Neotex's data directory
      -- predictable.
      treesitter.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })

      -- Filetypes for which Neotex intentionally does not start
      -- Tree-sitter. TeX/LaTeX continues to use Vim's syntax engine.
      local disabled = {
        bibtex = true,
        cls = true,
        context = true,
        latex = true,
        plaintex = true,
        tex = true,
      }

      -- Neovim 0.12 provides Tree-sitter highlighting natively.
      --
      -- Start Tree-sitter when entering a supported filetype. pcall()
      -- prevents a missing parser from interrupting buffer startup.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup(
          "NeotexTreesitter",
          { clear = true }
        ),

        callback = function(event)
          local bufnr = event.buf
          local ft = vim.bo[bufnr].filetype

          if disabled[ft] then
            return
          end

          local lang = vim.treesitter.language.get_lang(ft)

          if not lang then
            return
          end

          local ok = pcall(
            vim.treesitter.start,
            bufnr,
            lang
          )

          -- Only configure Tree-sitter indentation if Tree-sitter
          -- successfully started for this buffer.
          --
          -- Python is excluded because Tree-sitter indentation can
          -- behave poorly for significant-whitespace languages.
          if ok and ft ~= "python" then
            vim.bo[bufnr].indentexpr =
              "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      -- Keep Vim's built-in syntax highlighting for TeX/LaTeX.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup(
          "NeotexLatexSyntax",
          { clear = true }
        ),

        pattern = {
          "tex",
          "latex",
          "plaintex",
          "context",
        },

        callback = function(event)
          pcall(vim.treesitter.stop, event.buf)
          vim.bo[event.buf].syntax = "tex"
        end,
      })
    end,
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    event = {
      "BufReadPost",
      "BufNewFile",
    },

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },

    config = function()
      require("ts_context_commentstring").setup({})
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    lazy = true,

    ft = {
      "html",
      "xml",
      "jsx",
      "tsx",
      "vue",
      "svelte",
      "php",
      "markdown",
    },

    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },

    config = function()
      require("nvim-ts-autotag").setup({})
    end,
  },
}
