{
  lib,
  pkgs,
  config,
  ...
}: let
  palette = config.my.colors.palette.withoutHashtag;
in {
  config = lib.mkIf config.my.roles.gaming.enable {
    home.packages = [pkgs.discord];

    programs.mangohud = {
      enable = true;
      enableSessionWide = true;
    };

    # can't use the `programs.mangohud.settings` option as it sorts the keys, which changes the rendering order
    xdg.configFile."MangoHud/MangoHud.conf".text = ''
      font_size=18
      position=top-left
      toggle_hud=Shift_R+F12

      background_color=${palette.base}
      background_alpha=0
      text_color=${palette.text}
      round_corners=0

      gpu_stats
      gpu_temp
      gpu_load_change
      gpu_load_value=50,90
      gpu_load_color=${palette.text},${palette.tangerine},${palette.cherry}
      gpu_text=GPU
      gpu_color=${palette.green}

      cpu_stats
      cpu_temp
      cpu_load_change
      cpu_load_value=50,90
      cpu_load_color=${palette.text},${palette.tangerine},${palette.cherry}
      cpu_color=${palette.teal}
      cpu_text=CPU
      core_load_change

      fps
      engine_color=${palette.purple}

      frame_timing=1
      frametime_color=${palette.sand}
    '';
  };
}
