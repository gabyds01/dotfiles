{ pkgs, ... }:

{
  # =========================================================================
  # Virtualización y Contenedores
  # =========================================================================
  
  # Docker
  virtualisation.docker.enable = true;

  # KVM / QEMU / Libvirt
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };

  # GUI para gestión de máquinas virtuales
  programs.virt-manager.enable = true;

  # Confianza para la interfaz virtual de red de libvirt en el firewall
  networking.firewall.trustedInterfaces = [ "virbr0" ];
}
