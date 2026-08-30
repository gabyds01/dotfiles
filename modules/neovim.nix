{ pkgs, ... }:

let
  # Empaquetamos mizisu/django.nvim directamente desde GitHub ya que es muy nuevo
  django-nvim = pkgs.vimUtils.buildVimPlugin {
    name = "django-nvim";
    src = pkgs.fetchFromGitHub {
      owner = "mizisu";
      repo = "django.nvim";
      rev = "2615ca95f16ee74a86e9680f6b81a032f6e69b19"; # Commit con soporte blink
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

    # Opciones básicas generales de Neovim escritas en Lua embebido
    initLua = ''
      -- Opciones básicas del editor
      vim.opt.number = true            -- Mostrar número de línea
      vim.opt.relativenumber = true    -- Números relativos para saltos rápidos
      vim.opt.shiftwidth = 4           -- Indentación de 4 espacios (ideal para Python)
      vim.opt.tabstop = 4
      vim.opt.expandtab = true         -- Convertir tabs en espacios
      vim.opt.smartindent = true
      vim.opt.termguicolors = true     -- Colores RGB reales en terminal
      vim.opt.clipboard = "unnamedplus" -- Compartir portapapeles con el sistema

      vim.g.mapleader = " "            -- Espacio como tecla líder (Leader key)
    '';

    # Plugins instalados y configurados individualmente con Lua embebido
    plugins = with pkgs.vimPlugins; [

      # Iconos para tu statusline y el resto del editor
      nvim-web-devicons
      
      # Lualine configurado con el tema Kanagawa
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup({
            options = {
              theme = 'kanagawa', -- ¡Se acopla automáticamente a los colores!
              component_separators = { left = '', right = '' },
              section_separators = { left = '', right = '' },
              globalstatus = true, -- Una única barra elegante al fondo del editor
            }
          })
        '';
      }


      # === Tema Visual: Kanagawa ===
      {
        plugin = kanagawa-nvim;
        type = "lua";
        config = ''
          require('kanagawa').setup({
              compile = false,             -- Desactivado por compatibilidad con el Nix Store de solo lectura
              undercurl = true,            -- Soporte de subrayados curvados para terminales compatibles
              commentStyle = { italic = true },
              keywordStyle = { italic = true },
              transparent = false,         -- Cambia a 'true' si usas transparencia en tu terminal
              theme = "dragon",              -- Carga la variante dragon
              background = {               -- Mapea los valores de fondo claro/oscuro
                  dark = "dragon",           
                  light = "lotus"
              },
          })

          -- Aplicamos el tema de forma definitiva
          vim.cmd("colorscheme kanagawa")
        '';
      }

      # === Lote 1: Edición Básica ===

      # 1. Comment.nvim (gcc para comentar líneas)
      {
        plugin = comment-nvim;
        type = "lua";
        config = "require('Comment').setup()";
      }

      # 2. nvim-autopairs (cierre automático de caracteres)
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = "require('nvim-autopairs').setup()";
      }

      # 3. Oil.nvim (navegador de archivos en el buffer)
      {
        plugin = oil-nvim;
        type = "lua";
        config = ''
          require('oil').setup({
            default_file_explorer = true,
          })
          -- Atajo rápido para abrir Oil con '-'
          vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Abrir directorio actual con Oil" })
        '';
      }

      # === Lote 2: Sintaxis y Búsqueda ===

      # 1. Treesitter: Resaltado gramatical inteligente
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          -- En Neovim moderno (0.11+), Treesitter se activa mediante autocomandos nativos
          vim.api.nvim_create_autocmd('FileType', {
            pattern = { 'python', 'html', 'htmldjango', 'json', 'yaml', 'bash', 'gitconfig' },
            callback = function() vim.treesitter.start() end,
          })
        '';
      }

      # 2. Telescope: El buscador difuso definitivo (requiere plenary-nvim)
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          local builtin = require('telescope.builtin')
          -- Atajos para Telescope
          vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope: Buscar Archivos' })
          vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope: Buscar Texto (ripgrep)' })
          vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope: Ver Buffers Abiertos' })
          vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope: Buscar en la Ayuda' })
        '';
      }

      # === Lote 3: Integración de Git ===

      # 1. Gitsigns: Indicadores de Git en la barra lateral
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup({
            current_line_blame = true, -- Muestra quién escribió la línea actual (Git Blame inline)
          })
        '';
      }

      # 2. Neogit: Interfaz interactiva potente
      {
        plugin = neogit;
        type = "lua";
        config = ''
          require('neogit').setup({
            kind = "floating", -- Abre Neogit de forma elegante en una ventana flotante
          })
          -- Atajo rápido: <leader>gs (Git Status) para abrir Neogit
          vim.keymap.set("n", "<leader>gs", "<cmd>Neogit<cr>", { desc = "Git: Abrir Neogit" })
        '';
      }

      # 3. Diffview: Comparación interactiva de diferencias
      {
        plugin = diffview-nvim;
        type = "lua";
        config = ''
          -- Atajos para abrir y cerrar Diffview
          vim.keymap.set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Git: Ver diferencias del proyecto" })
          vim.keymap.set("n", "<leader>gc", "<cmd>DiffviewClose<cr>", { desc = "Git: Cerrar Diffview" })
        '';
      }

      # === Lote 4: Python, Django e Inteligencia ===

      # 1. Configuración base de LSP (basado en vim.lsp.enable en Neovim moderno)
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          vim.lsp.enable('basedpyright')
        '';
      }

      # 2. Autocompletado de alto rendimiento (Blink.cmp) con soporte para Django
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

      # 3. Selector visual de Entornos Virtuales (.venv, poetry, etc.)
      {
        plugin = venv-selector-nvim;
        type = "lua";
        config = ''
          require('venv-selector').setup({
            options = {
              on_venv_activate_callback = nil,
            }
          })
          -- Atajo rápido para elegir entorno: <leader>vs
          vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "Python: Elegir entorno virtual" })
        '';
      }

      # Snacks.nvim: Requerido por django.nvim para pickers e inputs de UI
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
            -- Activamos explícitamente el Picker para que django.nvim lo utilice
            picker = { enabled = true },
          })
        '';
      }

      # 4. Plugin customizado de utilidades Django (empaquetado arriba)
      {
        plugin = django-nvim;
        type = "lua";
        config = ''
          require('django').setup({})
          -- Atajos predeterminados del plugin para buscar vistas, modelos y abrir shell
          vim.keymap.set("n", "<leader>djv", "<cmd>DjangoViews<cr>", { desc = "Django: Buscar vistas" })
          vim.keymap.set("n", "<leader>djm", "<cmd>DjangoModels<cr>", { desc = "Django: Buscar modelos" })
          vim.keymap.set("n", "<leader>djs", "<cmd>DjangoShell<cr>", { desc = "Django: Toggle Shell" })
        '';
      }

      # 5. Formateo declarativo al guardar (Conform.nvim)
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
            format_on_save = {
              timeout_ms = 500,
              lsp_format = "fallback",
            },
          })
        '';
      }

      # 6. Linters asíncronos en segundo plano (Nvim-lint)
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
          -- Autocomando para ejecutar el linter automáticamente al guardar
          vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            callback = function()
              lint.try_lint()
            end,
          })
        '';
      }

    ];

    # Dependencias del sistema necesarias
    extraPackages = with pkgs; [
      ripgrep      # Requerido por Telescope para buscar texto
      fd           # Mejora dramática de rendimiento en búsquedas de Telescope
      wl-clipboard # Para entornos Wayland
      xclip        # Para entornos X11
      git

      # Binarios para desarrollo en Python & Django
      basedpyright # El servidor de lenguajes (LSP) para Python
      ruff         # Formateador e import-organizer ultra rápido en Rust
      djlint       # Linter y formateador excelente para Django HTML templates
    ];
  };
}
