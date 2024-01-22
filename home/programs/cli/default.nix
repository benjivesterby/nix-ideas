{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./bat.nix
    ./btop.nix
    ./direnv.nix
    ./eza.nix
    ./fish.nix
    ./git.nix
    ./helix.nix
    ./podman.nix
    ./skim.nix
    ./ssh.nix
    ./starship.nix
    ./zellij.nix
    ./zoxide.nix
    ./neovim
  ];
  config = lib.mkIf config.my.roles.terminal.enable {
    home.packages = with pkgs; [
      megatools
      ast-grep
      choose
      du-dust
      dysk
      fclones
      fd
      rargs
      ripgrep
      rm-improved
      sshfs
      xcp
      gh
      killall
    ];

    programs.nix-index.enable = true;
  };
}
