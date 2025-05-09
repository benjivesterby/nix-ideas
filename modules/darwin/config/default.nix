{
  pkgs,
  lib,
  ...
}:
{
  options = {
    my.configDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      apply = toString;
      default = null;
      description = "Location of the nix config directory (this repo)";
    };
  };

  config = {
    system.stateVersion = 4;

    nix = {
      optimise.automatic = true;
      gc = {
        automatic = true;
        interval = {
          Day = 7;
        };
        options = "--delete-older-than 7d";
      };
    };

    environment = {
      systemPackages = [
        # FIXME: move to kunkun (package it)
        # pkgs.raycast
        pkgs.nightly.nh
        pkgs.deno # for kunkun
      ];
      shells = [ pkgs.fish ];
      variables.EDITOR = "nvim";
      variables.MOZ_LEGACY_PROFILES = "1";
    };

    launchd.user.envVariables.MOZ_LEGACY_PROFILES = "1";

    programs.fish.enable = true;
    homebrew.enable = true;
    security.pam.services.sudo_local.touchIdAuth = true;

    system.defaults = {
      dock = {
        autohide = true;
        orientation = "right";
        mru-spaces = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
      };

      NSGlobalDomain = {
        _HIHideMenuBar = true;
      };
    };
  };
}
