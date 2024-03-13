{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.my.roles.graphical;
  palette = config.my.colors.palette.withoutHashtag;
  monitors = rec {
    primary = cfg.monitors.primary.id;
    secondary = cfg.monitors.secondary.id or primary;
  };
  layout = "hy3";
  movefocus = "hy3:movefocus";
  movewindow = "hy3:movewindow";
in {
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      plugins = [
        pkgs.hyprlandPlugins.hy3
      ];

      settings = {
        monitor = ",preferred,auto,1";
        workspace = [
          "1,monitor:${monitors.primary}"
          "3,monitor:${monitors.primary}"
          "2,monitor:${monitors.primary}"
          "4,monitor:${monitors.primary}"
          "5,monitor:${monitors.primary}"
          "6,monitor:${monitors.primary}"
          "7,monitor:${monitors.primary}"
          "8,monitor:${monitors.primary}"
          "9,monitor:${monitors.primary}"
          "10,monitor:${monitors.secondary}"
        ];

        exec-once = [
          #(lib.getExe pkgs.hyprpaper)
          (lib.getExe pkgs.hypridle)
          (lib.getExe pkgs.firefox)
          "element-desktop"
          (lib.getExe pkgs.discord)
        ];

        windowrulev2 = [
          "workspace 1 silent, class:firefox"
          "workspace 6 silent, class:Steam"
          "workspace 9 silent, class:Element"
          "workspace 9 silent, class:discord"
          "workspace 10 silent, class:Slack"

          "float, class:ulauncher"
          "float, class:pavucontrol"
          "float, class:flameshot"
          "noanim, class:flameshot"
        ];

        layerrule = [
          "blur, swaync-control-center"
          "ignorealpha 0.5, swaync-control-center"

          "blur, swaync-notification-window"
          "ignorealpha 0.5, swaync-notification-window"

          "blur, anyrun"
        ];

        input = {
          kb_layout = "fr,us";
          kb_options = "grp:alt_shift_toggle";

          follow_mouse = 1;
          float_switch_override_focus = 0;
          touchpad = {
            natural_scroll = true;
          };
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.inactive_border" = lib.mkForce "rgba(59595900)";
          layout = layout;
        };

        decoration = {
          rounding = 10;
          blur.size = 3;
          drop_shadow = true;
          shadow_range = 20;
          shadow_render_power = 10;
          "col.shadow" = lib.mkForce "rgba(1a1a1abb)";
        };

        animations = {
          enabled = true;
          bezier = [
            "in-out, .65, -0.01, 0, .95"
          ];
          animation = [
            "windows, 1, 7, default"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 5, in-out, slide"
          ];
        };

        dwindle = {
          preserve_split = true;
          force_split = 2;
        };
        master.new_is_master = false;
        gestures.workspace_swipe = true;

        misc = {
          enable_swallow = true;
          swallow_regex = "^(${cfg.terminal})$";
        };

        bind = [
          "SUPER, return, exec, ${cfg.terminal}"
          "SUPER, L, exec, ${lib.getExe pkgs.hyprlock}"
          "SUPER SHIFT, Q, killactive,"
          "SUPER, M, exit,"
          "SUPER, E, exec, firefox"
          "SUPER, V, pin,"
          "SUPER, F, fullscreen,"
          "SUPER, N, exec, ${lib.getExe' pkgs.swaynotificationcenter "swaync-client"} -t"
          "SUPER SHIFT, F, togglefloating,"
          "SUPER, space, exec, anyrun"
          "SUPER, P, exec, hyprfreeze -a" # Pause active program
          "SUPER, backspace, togglesplit,"
          "SUPER, R, exec, flameshot gui"
          "SUPERSHIFT, delete, exec, scratchpad"
          "SUPER, delete, exec, scratchpad -g"
          "SUPER, left, ${movefocus}, l"
          "SUPER, right, ${movefocus}, r"
          "SUPER, up, ${movefocus}, u"
          "SUPER, down, ${movefocus}, d"
          "SUPER SHIFT, left, ${movewindow}, l"
          "SUPER SHIFT, right, ${movewindow}, r"
          "SUPER SHIFT, up, ${movewindow}, u"
          "SUPER SHIFT, down, ${movewindow}, d"
          "SUPER, 10, workspace, 1"
          "SUPER, 11, workspace, 2"
          "SUPER, 12, workspace, 3"
          "SUPER, 13, workspace, 4"
          "SUPER, 14, workspace, 5"
          "SUPER, 15, workspace, 6"
          "SUPER, 16, workspace, 7"
          "SUPER, 17, workspace, 8"
          "SUPER, 18, workspace, 9"
          "SUPER, 19, workspace, 10"
          "SUPER CONTROL, right, workspace, e+1"
          "SUPER CONTROL, left, workspace, e-1"
          "SUPER, mouse_down, workspace, e+1"
          "SUPER, mouse_up, workspace, e-1"
          "SUPER SHIFT, 10, movetoworkspacesilent, 1"
          "SUPER SHIFT, 11, movetoworkspacesilent, 2"
          "SUPER SHIFT, 12, movetoworkspacesilent, 3"
          "SUPER SHIFT, 13, movetoworkspacesilent, 4"
          "SUPER SHIFT, 14, movetoworkspacesilent, 5"
          "SUPER SHIFT, 15, movetoworkspacesilent, 6"
          "SUPER SHIFT, 16, movetoworkspacesilent, 7"
          "SUPER SHIFT, 17, movetoworkspacesilent, 8"
          "SUPER SHIFT, 18, movetoworkspacesilent, 9"
          "SUPER SHIFT, 19, movetoworkspacesilent, 10"
        ];

        bindm = [
          "SUPER, mouse:272, movewindow"
          "SUPER, mouse:273, resizewindow"
        ];

        bindel = [
          ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
          ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ];

        bindl = [
          ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ];

        # "plugin:hyprfocus" = {
        #   enabled = false;
        #   keyboard_focus_animation = "flash";
        #   mouse_focus_animation = "flash";
        #
        #   bezier = [
        #     "bezIn, 0.5,0.0,1.0,0.5"
        #     "bezOut, 0.0,0.5,0.5,1.0"
        #   ];
        #
        #   flash = {
        #     flash_opacity = 0.7;
        #     in_speed = 1;
        #     in_bezier = "bezIn";
        #     out_speed = 3;
        #     out_bezier = "bezOut";
        #   };
        # };
      };
    };

    xdg.configFile."hypr/hyprlock.conf".text =
      # hyprlang
      ''
        background {
            path = screenshot
            blur_passes = 3
            blur_size = 7
        }

        input-field {
            size = 300, 50
            outline_thickness = 3
            dots_size = 0.33 # Scale of input-field height, 0.2 - 0.8
            dots_spacing = 0.15 # Scale of dots' absolute size, 0.0 - 1.0
            dots_center = false
            outer_color = rgb(${palette.crust})
            inner_color = rgb(${palette.text})
            font_color = rgb(${palette.base})
            fade_on_empty = true
            hide_input = false
            position = 0, -20
            halign = center
            valign = center
        }
      '';

    xdg.configFile."hypr/hypridle.conf".text =
      # hyprlang
      ''
        listener {
            timeout = 900 # 15 minutes
            on-timeout = hyprlock
        }
      '';

    home.packages = with inputs.hyprland-contrib.packages.${pkgs.system}; [
      grimblast # TODO: see if i keep this
      hyprprop
      scratchpad
      pkgs.my.hyprfreeze
    ];
  };
}
