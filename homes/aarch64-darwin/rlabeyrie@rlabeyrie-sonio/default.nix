{ lib, ... }:
{
  my.roles.terminal.enable = true;
  my.roles.graphical = {
    enable = true;
    fonts.sizes.terminal = 12;
    installAllFonts = true;
  };
  programs.kitty.enable = lib.mkForce true;

  programs.git.includes = [
    {
      condition = "gitdir:~/sonio/";
      contents = {
        user = {
          name = "Rémi Labeyrie";
          email = "remi.labeyrie@sonio.ai";
          # signingKey = "BC3E47212B5DA44E";
        };
      };
    }
  ];
}
