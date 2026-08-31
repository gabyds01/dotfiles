{ pkgs, ... }:

let
  # Empaquetado directo de mizisu/django.nvim desde GitHub
  django-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "django-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "mizisu";
      repo = "django.nvim";
      rev = "2615ca95f16ee74a86e9680f6b81a032f6e69b19";
      sha256 = "sha256-n/AO6bUB0f+iRKxNQeQrHrzNjoud6/HfXhPDtvpDynM=";
    };
  };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # =========================================================================
    # Configuración Base de Neovim (init.lua)
    # =========================================================================
    initLua = ''
      -- Opciones básicas del editor
      vim.opt.number = true             -- Mostrar número de línea absoluto
      vim.opt.relativenumber = true     -- Números relativos para navegación eficiente
      vim.opt.shiftwidth = 4            -- Indentación de 4 espacios
      vim.opt.tabstop = 4
      vim.opt.expandtab = true          -- Convertir tabs en espacios
      vim.opt.smartindent = true
      vim.opt.termguicolors = true      -- Soporte para paleta de colores RGB de 24 bits
      vim.opt.clipboard = "unnamedplus" -- Sincronizar con el portapapeles del sistema

      -- Corrector ortográfico integrado
      vim.opt.spelllang = { "es", "en" } -- Diccionarios para español e inglés
      vim.opt.spell = false              -- Desactivado globalmente por defecto

      -- Guía visual en la columna 80
      vim.opt.colorcolumn = "80"

      -- Tecla líder (Leader key)
      vim.g.mapleader = " "
    '';

    # =========================================================================
    # Plugins y Extensiones
    # =========================================================================
    plugins = with pkgs.vimPlugins; [
      # --- Tema Visual y Estética ---
      {
        plugin = kanagawa-nvim;
        type = "lua";
        config = ''
          require('kanagawa').setup({
            compile = false,
            undercurl = true,
            commentStyle = { italic = true },
            keywordStyle = { italic = true },
            transparent = false,
            theme = "dragon",
            background = { dark = "dragon", light = "lotus" },
          })
          vim.cmd("colorscheme kanagawa")
        '';
      }

      # --- Barra de Estado e Iconos ---
      nvim-web-devicons
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup({
            options = {
              theme = 'kanagawa',
              component_separators = { left = '', right = '' },
              section_separators = { left = '', right = '' },
              globalstatus = true,
            }
          })
        '';
      }

      # --- Lote 1: Edición Básica y Explorador ---
      {
        plugin = comment-nvim;
        type = "lua";
        config = "require('Comment').setup()";
      }
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = "require('nvim-autopairs').setup()";
      }
      {
        plugin = oil-nvim;
        type = "lua";
        config = ''
          require('oil').setup({ default_file_explorer = true })
          vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Abrir directorio con Oil" })
        '';
      }

      # --- Lote 2: Sintaxis (Treesitter) y Búsqueda Difusa (Telescope) ---
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'python', 'html', 'htmldjango', 'json', 'yaml', 'bash', 'gitconfig', 'markdown' },
            callback = function() vim.treesitter.start() end,
          })
        '';
      }
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope: Buscar Archivos' })
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope: Buscar Texto' })
          vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope: Ver Buffers' })
          
          -- Cargar extensiones de Telescope
          require('telescope').load_extension('fzf')
        '';
      }
      {
        plugin = telescope-fzf-native-nvim;
        type = "lua";
        config = "";
      }

      # --- Lote 3: Control de Versiones (Git) ---
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = "require('gitsigns').setup({ current_line_blame = true })";
      }
      {
        plugin = neogit;
        type = "lua";
        config = ''
          require('neogit').setup({ kind = "floating" })
          vim.keymap.set("n", "<leader>gs", "<cmd>Neogit<cr>", { desc = "Git: Abrir Neogit" })
        '';
      }
      {
        plugin = diffview-nvim;
        type = "lua";
        config = ''
          vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git: Ver diferencias" })
          vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "Git: Cerrar diferencias" })
        '';
      }

      # --- Lote 4: LSP, Autocompletado, Python y Django ---
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = "vim.lsp.enable('basedpyright')";
      }
      {
        plugin = blink-cmp;
        type = "lua";
        config = ''
          require('blink.cmp').setup({
            keymap = { preset = 'default' },
            sources = {
              default = { 'lsp', 'path', 'snippets', 'buffer', 'django' },
              providers = {
                django = {
                  name = "Django",
                  module = "django.completions.blink",
                  async = true,
                },
              },
            },
          })
        '';
      }
      {
        plugin = venv-selector-nvim;
        type = "lua";
        config = ''
          require('venv-selector').setup({ options = { on_venv_activate_callback = nil } })
          vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "Python: Elegir entorno virtual" })
        '';
      }
      {
        plugin = django-nvim;
        type = "lua";
        config = ''
          require('django').setup({})
          vim.keymap.set("n", "<leader>djv", "<cmd>DjangoViews<cr>", { desc = "Django: Buscar vistas" })
          vim.keymap.set("n", "<leader>djm", "<cmd>DjangoModels<cr>", { desc = "Django: Buscar modelos" })
          vim.keymap.set("n", "<leader>djs", "<cmd>DjangoShell<cr>", { desc = "Django: Toggle Shell" })
        '';
      }
      {
        plugin = conform-nvim;
        type = "lua";
        config = ''
          require('conform').setup({
            formatters_by_ft = {
              python = { "ruff_format" },
              html = { "djlint" },
              htmldjango = { "djlint" },
              lua = { "stylua" },
            },
            format_on_save = { timeout_ms = 100, lsp_format = "fallback" },
          })
        '';
      }
      {
        plugin = nvim-lint;
        type = "lua";
        config = ''
          local lint = require('lint')
          lint.linters_by_ft = {
            python = { 'ruff' },
            html = { 'djlint' },
            htmldjango = { 'djlint' },
          }
          vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            callback = function() lint.try_lint() end,
          })
        '';
      }

      # --- Lote 5: Obsidian y Gestión de Notas Markdown ---
      {
        plugin = plenary-nvim;
        type = "lua";
        config = "";
      }
      {
        plugin = obsidian-nvim;
        type = "lua";
        config = ''
          require("obsidian").setup({
            workspaces = { { name = "personal", path = "~/vaults/personal" } },
            notes_subdir = "notes",
            daily_notes = { folder = "dailies", date_format = "%Y-%m-%d", alias_format = "%B %d, %Y" },
            ui = { enable = false },
            legacy_commands = false,
          })

          -- Configuración recomendada para buffers Markdown
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function()
              vim.opt_local.colorcolumn = ""    -- Desactiva la línea guía en notas
              vim.opt_local.wrap = true         -- Ajuste de líneas largas a la pantalla
              vim.opt_local.linebreak = true    -- Cortar por palabra completa
              vim.opt_local.textwidth = 0

              -- Seguir enlaces con gf (Obsidian o nativo)
              vim.keymap.set("n", "gf", function()
                if require("obsidian").util.cursor_on_markdown_link() then
                  return "<cmd>Obsidian follow_link<CR>"
                else
                  return "gf"
                end
              end, { noremap = false, expr = true, buffer = true, desc = "Obsidian: Seguir enlace" })

              -- Alternar casillas de verificación (Checkboxes)
              vim.keymap.set("n", "<leader>ch", "<cmd>Obsidian toggle_checkbox<CR>", { buffer = true, desc = "Obsidian: Alternar casilla" })
            end,
          })
        '';
      }
      {
        plugin = render-markdown-nvim;
        type = "lua";
        config = ''
          require('render-markdown').setup({
            heading = {
              enabled = true,
              icons = { " 󰲡 ", " 󰲣 ", " 󰲥 ", " 󰲧 ", " 󰲩 ", " 󰲫 " },
            },
            checkbox = {
              enabled = true,
              unchecked = { icon = "󰄱 " },
              checked = { icon = " " },
            },
            pipe_table = {
              enabled = true,
              preset = "round",
            },
            quote = {
              enabled = true,
            },
          })
        '';
      }
      {
        plugin = img-clip-nvim;
        type = "lua";
        config = ''
          require('img-clip').setup({
            default = { dir_path = "attachments", use_absolute_path = false, insert_mode_after_paste = false }
          })
          vim.keymap.set("n", "<leader>ip", "<cmd>PasteImage<cr>", { desc = "Markdown: Pegar imagen" })
        '';
      }
      {
        plugin = todo-comments-nvim;
        type = "lua";
        config = ''
          require('todo-comments').setup({})
          vim.keymap.set("n", "<leader>td", "<cmd>TodoTelescope<cr>", { desc = "Buscar TODOs" })
        '';
      }
      {
        plugin = which-key-nvim;
        type = "lua";
        config = "require('which-key').setup({ preset = 'modern' })";
      }

      # --- Lote 6: Productividad y Edición Avanzada ---
      # Snacks.nvim (Requerido por django.nvim y utilidades QoL)
      {
        plugin = snacks-nvim;
        type = "lua";
        config = ''
          require('snacks').setup({
            bigfile = { enabled = true },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            statuscolumn = { enabled = true },
            words = { enabled = true },
            picker = { enabled = true },
          })
        '';
      }

      # Nvim-surround: Manipulación rápida de delimitadores (comillas, paréntesis, tags)
      {
        plugin = nvim-surround;
        type = "lua";
        config = "require('nvim-surround').setup({})";
      }

      # Grug-far: Buscar y reemplazar masivo
      {
        plugin = grug-far-nvim;
        type = "lua";
        config = ''
          require('grug-far').setup({})
          vim.keymap.set("n", "<leader>sr", "<cmd>GrugFar<cr>", { desc = "Buscar y Reemplazar (Grug-Far)" })
        '';
      }

      # Yanky: Historial interactivo del portapapeles
      {
        plugin = yanky-nvim;
        type = "lua";
        config = ''
          require("yanky").setup({})

          -- Carga segura de la extensión dentro de Yanky
          pcall(function()
            require('telescope').load_extension('yanky')
          end)

          -- Atajos para pegar del historial de Yanky
          vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)")
          vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)")
          vim.keymap.set("n", "<leader>p", "<cmd>Telescope yanky<cr>", { desc = "Yanky: Historial del portapapeles" })
        '';
      }

      # Persistence: Restauración y guardado automático de sesiones
      {
        plugin = persistence-nvim;
        type = "lua";
        config = ''
          require("persistence").setup({})
          vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Sesión: Restaurar directorio" })
          vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Sesión: Restaurar última" })
        '';
      }

      # Trouble: Panel de diagnósticos, advertencias y referencias
      {
        plugin = trouble-nvim;
        type = "lua";
        config = ''
          require("trouble").setup({})
          vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble: Ver diagnósticos" })
        '';
      }
    ];

    # =========================================================================
    # Herramientas del Sistema y Servidores LSP
    # =========================================================================
    extraPackages = with pkgs; [
      ripgrep
      fd
      git
      wl-clipboard
      xclip

      # Servidores y formateadores de desarrollo
      basedpyright
      ruff
      djlint
    ];
  };
}
