{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.my.roles.graphical.enabled {
    programs.zed-editor = {
      enable = true;

      extensions = [
        "nix"
        "toml"
      ];

      userSettings = {
        assistant = {
          enabled = true;

          default_model = {
            provider = "anthropic";
            model = "claude-3-5-opus-latest";
          };
        };

        node = {
          path = lib.getExe pkgs.nodejs;
          npm_path = lib.getExe' pkgs.nodejs "npm";
        };

        hour_format = "hour24";
        auto_update = false;

        terminal = {
          font_family = config.my.fonts.aporetic-sans-mono.name;
        };

        lsp = {
          nix = {
            binary = {
              path_lookup = true;
            };
          };
        };

        vim_mode = true;

        # Tell Zed to use direnv and direnv can use a flake.nix environment
        load_direnv = "shell_hook";
        base_keymap = "VSCode";

        theme = {
          mode = "system";
          light = "One Light";
          dark = "One Dark";
        };

        show_whitespaces = "all";
        ui_font_size = 16;
        buffer_font_size = 16;
      };
    };
  };
}
