{ pkgs, ... }:

{
  # =========================================================================
  # Virtualización, Contenedores y Gestión de Máquinas Virtuales
  # =========================================================================

  # Demonio de Docker para contenedores
  virtualisation.docker.enable = true;

  # Demonio de Libvirt / QEMU / KVM para virtualización completa
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ]; # Soporte de carpetas compartidas de alto rendimiento
  };

  # Interfaz gráfica (GUI) para crear y gestionar máquinas virtuales
  programs.virt-manager.enable = true;

  # Permitir el tráfico sin bloqueo en el puente de red virtual de Libvirt
  networking.firewall.trustedInterfaces = [ "virbr0" ];
}
