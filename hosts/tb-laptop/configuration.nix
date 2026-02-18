{
  pkgs,
  inputs,
  flake,
  ...
}:
{
  imports = [
    flake.nixosModules.default
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-intel-gen5
    ./hardware.nix
  ];

  my.configDir = "/home/calops/nix";

  networking.hostName = "tb-laptop";
  time.timeZone = "Europe/Paris";

  services.xserver.xkb = {
    layout = "fr";
    variant = "azerty";
  };
  console.keyMap = "fr";

  my.roles = {
    graphical.enable = true;
    audio.enable = true;
    printing.enable = true;
    bluetooth.enable = true;
  };

  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics = {
    enable = true;
    extraPackages = [
      pkgs.intel-media-driver
      pkgs.vpl-gpu-rt
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = pkgs.linuxPackages_testing;

  # SSD periodic trimming
  services.fstrim.enable = true;

  users.users.calops = {
    isNormalUser = true;
    description = "Rémi Labeyrie";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.fish;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024; # 64 GiB
    }
  ];
}
