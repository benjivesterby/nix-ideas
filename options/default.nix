{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./terminal.nix
    ./graphical.nix
    ./gaming.nix
    ./audio.nix
  ];

  options = {
    my.roles.configDir = lib.mkOption {
      type = lib.types.str;
      description = "Location of the nix config directory (this repo)";
    };
    my.roles.bluetooth.enable = lib.mkEnableOption "Bluetooth support";
    my.roles.printing.enable = lib.mkEnableOption "Printing";
    my.isNixOs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether this is a NixOS system";
    };
    my.configurationName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the configuration";
    };
    my.stateVersion = lib.mkOption {
      type = lib.types.str;
      description = "Version of nixpkgs";
    };
  };

  config = {
    my.roles.configDir =
      if config.my.isNixOs
      then "/etc/nixos/config"
      else "${config.xdg.configHome}/home-manager/config";

    stylix = let
      palette = config.my.colors.palette.withoutHashtag;
    in {
      image = pkgs.fetchurl {
        url = "https://user-images.githubusercontent.com/4097716/247954752-8c7f3db1-e6a3-4f77-9cc4-262b3d929c36.png";
        sha256 = "sha256-O2AIOKMIgNwZ1/wEZyoVWiby6+FLrNWn9kiSw9rsOAI=";
      };
      autoEnable = true;
      polarity = config.my.colors.background;
      base16Scheme = {
        base00 = palette.base; # Default Background
        base01 = palette.surface0; # Lighter Background (Used for status bars)
        base02 = palette.surface1; # Selection Background
        base03 = palette.overlay0; # Comments, Invisibles, Line Highlighting
        base04 = palette.subtext0; # Dark Foreground (Used for status bars)
        base05 = palette.text; # Default Foreground, Caret, Delimiters, Operators
        base06 = palette.flamingo; # Light Foreground (Not often used)
        base07 = palette.navy; # Light Background (Not often used)
        base08 = palette.red; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
        base09 = palette.peach; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
        base0A = palette.sand; # Classes, Markup Bold, Search Text Background
        base0B = palette.green; # Strings, Inherited Class, Markup Code, Diff Inserted
        base0C = palette.teal; # Support, Regular Expressions, Escape Characters, Markup Quotes
        base0D = palette.blue; # Functions, Methods, Attribute IDs, Headings
        base0E = palette.purple; # Keywords, Storage, Selector, Markup Italic, Diff Changed
        base0F = palette.cherry; # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
      };
    };
  };
}
