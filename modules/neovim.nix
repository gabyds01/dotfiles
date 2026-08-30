{ pkgs, ... }:

let
  # Empaquetamos mizisu/django.nvim directamente desde GitHub
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

    # Opciones básicas generales de Neovim
    initLua = ''
      -- Opciones básicas del editor
      vim.opt.number = true            -- Mostrar número de línea
      vim.opt.relativenumber = true    -- Números relativos para saltos rápidos
      vim.opt.shiftwidth = 4           -- Indentación de 4 espacios
      vim.opt.tabstop = 4
      vim.opt.expandtab = true         -- Convertir tabs en espacios
      vim.opt.smartindent = true
      vim.opt.termguicolors = true     -- Colores RGB reales en terminal
      vim.opt.clipboard = "unnamedplus" -- Compartir portapapeles con el sistema

      -- Corrector ortográfico nativo para escritura de notas
      vim.opt.spelllang = { "es", "en" } -- Soporte para español e inglés
      vim.opt.spell = false             -- Desactivado por defecto (se activa por buffer con :set spell)

      -- Dibuja una línea vertical sutil en la columna 80 como guía de estilo
      vim.opt.colorcolumn = "80"

      vim.g.mapleader = " "            -- Espacio como tecla líder (Leader key)
    '';

    plugins = with pkgs.vimPlugins; [
      # === Tema Visual ===
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

      # === Barra de Estado e Iconos ===
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

      # === Lote 1: Edición Básica ===
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

      # === Lote 2: Sintaxis y Búsqueda ===
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
      # Buscador rápido FZF compilado en C para Telescope
      {
        plugin = telescope-fzf-native-nvim;
        type = "lua";
        config = "";
      }

      # === Lote 3: Integración de Git ===
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

      # === Lote 4: Python, Django e Inteligencia ===
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

      # === Lote 5 y 6: Obsidian y Productividad de Notas ===
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

            -- Desactiva los comandos antiguos estilo CamelCase
            legacy_commands = false,
          })

          -- Configuración estándar y recomendada de atajos para buffers Markdown
          vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function()
            -- Desactiva por completo la línea guía vertical de 80 caracteres en notas
              vim.opt_local.colorcolumn = ""

              -- Ajuste visual dinámico e inteligente de texto (Soft Wrap)
              vim.opt_local.wrap = true         -- Mostrar las líneas largas ajustadas a la pantalla
              vim.opt_local.linebreak = true    -- Cortar las palabras completas al ajustar, no a la mitad
              vim.opt_local.textwidth = 0       -- Desactivar corte físico (opcional, para notas más fluidas)

              -- Seguir enlaces con gf de forma nativa (o abrir por defecto si no es un enlace de Obsidian)
              vim.keymap.set("n", "gf", function()
                if require("obsidian").util.cursor_on_markdown_link() then
                  return "<cmd>Obsidian follow_link<CR>"
                else
                  return "gf"
                end
              end, { noremap = false, expr = true, buffer = true, desc = "Obsidian: Seguir enlace" })

              -- Alternar casillas de verificación (Checkboxes) con <leader>ch usando el nuevo comando espaciado
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
            -- La propiedad correcta para tablas es pipe_table y usa 'enabled'
            pipe_table = {
              enabled = true,
              preset = "round", -- Aplica bordes redondeados limpios y estéticos
            },
            -- 'quote' controla la activación de blockquotes y callouts de forma nativa
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

      # === Lote 7: Productividad, Edición Avanzada y Diagnósticos ===
      
      # 1. Snacks.nvim (Requerido por django.nvim y utilidades QoL)
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

      # 2. Nvim-surround: Control absoluto de comillas, paréntesis y tags
      {
        plugin = nvim-surround;
        type = "lua";
        config = "require('nvim-surround').setup({})";
      }

      # 3. Grug-far: Buscar y reemplazar de forma masiva y visual
      {
        plugin = grug-far-nvim;
        type = "lua";
        config = ''
          require('grug-far').setup({})
          vim.keymap.set("n", "<leader>sr", "<cmd>GrugFar<cr>", { desc = "Buscar y Reemplazar (Grug-Far)" })
        '';
      }

      # 4. Yanky: Historial interactivo del portapapeles
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

      # 5. Persistence: Gestión automática de sesiones
      {
        plugin = persistence-nvim;
        type = "lua";
        config = ''
          require("persistence").setup({})
          -- Atajos de teclado para restaurar sesiones
          vim.keymap.set("n", "<leader>qs", function() require("persistence").load() end, { desc = "Sesión: Restaurar directorio" })
          vim.keymap.set("n", "<leader>ql", function() require("persistence").load({ last = true }) end, { desc = "Sesión: Restaurar última" })
        '';
      }

      # 6. Trouble: Ventana de diagnósticos y corrector de estilo
      {
        plugin = trouble-nvim;
        type = "lua";
        config = ''
          require("trouble").setup({})
          vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble: Ver diagnósticos" })
        '';
      }
    ];

    # Servidores y linters inyectados de forma aislada
    extraPackages = with pkgs; [
      ripgrep
      fd
      git
      wl-clipboard
      xclip

      # Servidores de desarrollo
      basedpyright
      ruff
      djlint
    ];
  };
}
