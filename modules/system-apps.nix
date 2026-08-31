{ pkgs, ... }:

{
  # =========================================================================
  # Paquetes y Utilidades a Nivel de Sistema
  # Disponibles globalmente para todos los usuarios y tareas de mantenimiento
  # =========================================================================
  environment.systemPackages = with pkgs; [
    git        # Sistema de control de versiones
    gparted    # Herramienta gráfica de particionado de discos
    dnsmasq    # Servidor DNS/DHCP ligero (útil para redes y libvirt)
    btop       # Monitor de recursos y procesos en terminal
    fastfetch  # Información rápida del sistema en terminal
  ];
}
