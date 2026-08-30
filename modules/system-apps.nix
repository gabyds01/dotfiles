{ pkgs, ... }:

{
  # Aplicaciones indispensables a nivel global
  environment.systemPackages = with pkgs; [
    git
    gparted
    dnsmasq
    btop
    fastfetch
  ];
}
