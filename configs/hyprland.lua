-- =========================================================================
-- 1. Autostart — Aplicaciones que se lanzan al iniciar Hyprland
-- =========================================================================

hl.on("hyprland.start", function()
        hl.exec_cmd("alacritty")
end)

-- =========================================================================
-- 2. Monitores — Detección automática de pantallas
-- =========================================================================

-- Autodetectar cualquier monitor en su resolución y tasa de refresco preferidas
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- =========================================================================
-- 3. Entrada y Layout — Teclado y disposición de ventanas
-- =========================================================================

hl.config({
    input = {
        kb_layout = "latam",
    },
    general = {
        layout = "dwindle",
    }
})

-- =========================================================================
-- 4. Atajos de Teclado — Keybindings principales
-- =========================================================================

-- Abrir terminal (Alacritty)
hl.bind("SUPER + Return", hl.dsp.exec_cmd("alacritty"))

-- Cerrar la ventana activa
hl.bind("SUPER + Q", hl.dsp.window.close())

-- Salir de Hyprland de forma segura
hl.bind("SUPER + SHIFT + M", hl.dsp.exit())

-- =========================================================================
-- 5. Navegación de Ventanas — Foco y manipulación con ratón
-- =========================================================================

-- Cambiar el foco entre ventanas (estilo Vim: h/j/k/l)
hl.bind("SUPER + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "d" }))

-- Arrastrar y redimensionar ventanas flotantes con el ratón
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })    -- SUPER + Click Izquierdo
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })  -- SUPER + Click Derecho

-- =========================================================================
-- 6. Workspaces — Gestión de escritorios virtuales (1-9)
-- =========================================================================

-- Enlazar automáticamente los workspaces del 1 al 9
for i = 1, 9 do
    local ws = tostring(i)

    -- Cambiar al workspace correspondiente
    hl.bind("SUPER + " .. ws, hl.dsp.focus({ workspace = ws }))

    -- Mover la ventana activa al workspace correspondiente
    hl.bind("SUPER + SHIFT + " .. ws, hl.dsp.window.move({ workspace = ws }))
end

-- Cambiar de workspace con SUPER + Rueda del ratón
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- =========================================================================
-- 7. Estética — Bordes, gaps, esquinas redondeadas y blur
-- =========================================================================

hl.config({
    general = {
        border_size = 2,            -- Tamaño del borde (px)
        gaps_in = 6,                -- Espacio entre ventanas (px)
        gaps_out = 12,              -- Espacio con los bordes de la pantalla (px)

        -- Colores de borde: formato "rgba(RRGGBBAA)"
        ["col.active_border"] = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
        ["col.inactive_border"] = "rgba(595959aa)",
    },

    decoration = {
        rounding = 10,              -- Radio de esquinas redondeadas (px)
        rounding_power = 2.0,       -- 2.0 = circular, 4.0 = squircle estilo iOS

        active_opacity = 1.0,       -- Opacidad de la ventana activa
        inactive_opacity = 0.85,    -- Opacidad de las ventanas en segundo plano

        -- Desenfoque (blur) para ventanas translúcidas
        blur = {
            enabled = true,
            size = 8,
            passes = 3,             -- Más pasadas = blur más suave (mayor costo GPU)
            new_optimizations = true,
        }
    }
})

-- =========================================================================
-- 8. Reglas de Ventana — Comportamiento por aplicación
-- =========================================================================

-- Hacer que el control de volumen flote por defecto
-- TODO: agregar la qalculate
hl.window_rule({
    match = { class = "org.pulseaudio.pavucontrol" },
    float = true
})

-- Enviar Firefox al Workspace 1 (silencioso, sin cambiar de pantalla)
hl.window_rule({
    match = { class = "firefox" },
    workspace = "1 silent"
})

-- Opacidades personalizadas para Alacritty: "activa inactiva fullscreen"
hl.window_rule({
    match = { class = "Alacritty" },
    opacity = "0.9 override 0.8 override 1.0 override"
})
