{ flake, ... }:
{
  imports = [
    flake.homeModules.default
  ];

  my.roles.terminal.enable = true;

  my.roles.graphical = {
    installAllFonts = true;
    terminal = "kitty";

    niriExtraConfig = # kdl
      ''
        output "China Star Optoelectronics Technology Co., Ltd MNE507ZA2-3 Unknown" {
          mode "3072x1920@60.001"
          focus-at-startup
          variable-refresh-rate

          layout {
            default-column-width { proportion 0.5; }
          }
        }

        output "LG Electronics LG ULTRAFINE 505NTNHGX503" {
          position x=-3072 y=0
        }
      '';
  };

  programs.git.includes = [
    {
      condition = "gitdir:~/terabase/*";
      contents = {
        user = {
          name = "Rémi Labeyrie";
          email = "remilabeyrie@terabase.energy";
        };

        core.sshCommand = "ssh -vi ~/.ssh/terabase-bitbucket.pub";
      };
    }
  ];

  programs.ssh.matchBlocks.bitbucket = {
    hostname = "bitbucket.org";
    identitiesOnly = true;
    identityFile = "~/.ssh/terabase-bitbucket.pub";
  };
}
