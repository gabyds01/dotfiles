-- =========================================================================
-- 1. Autostart — Aplicaciones que se lanzan al iniciar Hyprland
-- =========================================================================

-- =========================================================================
-- 2. Monitores — Detección automática de pantallas
-- =========================================================================

-- Autodetectar cualquier monitor en su resolución y tasa de refresco preferidas
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- =========================================================================
-- 3. Entrada y Disposición (Input & Layout)
-- =========================================================================

hl.config({
    input = {
        kb_layout = "latam",
        touchpad = {
            tap_to_click = true,
            natural_scroll = true,
            disable_while_typing = true,
        }
    },
    general = {
        layout = "master",
    }
})

-- Gestos del touchpad: deslizar 3 dedos horizontalmente para cambiar de workspace
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- =========================================================================
-- 4. Atajos de Teclado (Keybindings) y Controles Multimedia
-- =========================================================================

-- --- Lanzadores y Aplicaciones Principales ---
-- Lanzador de aplicaciones (Fuzzel) con SUPER + Espacio
hl.bind("SUPER + space", hl.dsp.exec_cmd("fuzzel"))

-- Historial del Portapapeles (Clipse) ejecutado en Kitty
hl.bind("SUPER + V", hl.dsp.exec_cmd("kitty --class clipse -e clipse"))

-- Captura de pantalla del área seleccionada con anotaciones en Swappy
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))

-- Terminal (Kitty)
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))

-- Navegador web (Firefox)
hl.bind("SUPER + F", hl.dsp.exec_cmd("firefox"))

-- --- Gestión de Sesión y Bloqueo ---
-- Cerrar la ventana activa
hl.bind("SUPER + Q", hl.dsp.window.close())

-- Salir de la sesión de Hyprland
hl.bind("SUPER + SHIFT + M", hl.dsp.exit())

-- Bloqueo de pantalla manual
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

-- --- Controles Multimedia y Teclas Especiales (XF86) ---
-- Control de volumen mediante PipeWire (wpctl)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

-- Control de brillo de pantalla (brightnessctl)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))

-- =========================================================================
-- 5. Navegación y Manipulación de Ventanas
-- =========================================================================

-- Cambiar el foco entre ventanas (estilo Vim: h/j/k/l)
hl.bind("SUPER + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "d" }))

-- Enviar la ventana activa al espacio especial "magic" (Scratchpad)
hl.bind("SUPER + C", hl.dsp.window.move({ workspace = "special:magic" }))

-- Alternar visualización del espacio especial "magic"
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))

-- Arrastrar y redimensionar ventanas flotantes con el ratón
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })    -- SUPER + Clic Izquierdo (Mover)
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })  -- SUPER + Clic Derecho (Redimensionar)

-- --- Modo de Redimensionamiento (Submap Resize estilo Vim) ---
hl.bind("SUPER + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    -- hjkl para alterar dimensiones de la ventana activa
    hl.bind("h", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
    hl.bind("l", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
    hl.bind("k", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
    hl.bind("j", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

    -- Salir del modo de redimensionamiento
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- =========================================================================
-- 6. Workspaces — Gestión de escritorios virtuales (1-9)
-- =========================================================================

-- Enlazar automáticamente los workspaces del 1 al 9
for i = 1, 9 do
    local ws = tostring(i)

    -- Cambiar al workspace correspondiente (SUPER + [1-9])
    hl.bind("SUPER + " .. ws, hl.dsp.focus({ workspace = ws }))

    -- Mover la ventana activa al workspace correspondiente (SUPER + SHIFT + [1-9])
    hl.bind("SUPER + SHIFT + " .. ws, hl.dsp.window.move({ workspace = ws }))
end

-- Cambiar de workspace con SUPER + Rueda del ratón
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- =========================================================================
-- 7. Estética — Bordes, gaps, decoraciones y rendimiento
-- =========================================================================

hl.config({
    animations = {
        enabled = false,
    },

    general = {
        border_size = 2,           -- Grosor del borde en píxeles
        gaps_in = 3,               -- Espacio interior entre ventanas
        gaps_out = 6,              -- Espacio exterior con los bordes de pantalla

        -- Colores de borde en formato "rgba(RRGGBBAA)"
        ["col.active_border"] = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
        ["col.inactive_border"] = "rgba(595959aa)",
    },

    decoration = {
        rounding = 0,              -- Bordes rectos sin redondeo
        shadow = {
            enabled = false,
        },
        blur = {
            enabled = false,
        }
    },

    misc = {
        disable_hyprland_logo = true,     -- Desactiva el logo de inicio
        disable_splash_rendering = true,  -- Desactiva mensajes de bienvenida
        background_color = "0x111111",    -- Fondo plano gris oscuro de bajo consumo
    },

    xwayland = {
        force_zero_scaling = true,    -- Evita escalado borroso en aplicaciones XWayland
        use_nearest_neighbor = true,  -- Escalado nítido por vecino más cercano
    },
})

-- =========================================================================
-- 8. Reglas de Ventana (Window Rules)
-- =========================================================================

-- Enviar Firefox al Workspace 1 (silencioso, sin cambiar el foco de monitor)
hl.window_rule({
    match = { class = "firefox" },
    workspace = "1 silent"
})

-- Opacidades personalizadas para Kitty: "activa inactiva fullscreen"
hl.window_rule({
    match = { class = "kitty" },
    opacity = "0.9 override 0.8 override 1.0 override"
})

-- Portapapeles flotante
hl.window_rule({
    match = { class = "clipse" },
    float = true
})
