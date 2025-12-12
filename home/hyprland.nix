{ config, pkgs, ... }:

let
  # Catppuccin Latte colors
  catppuccin = {
    rosewater = "dc8a78";
    flamingo = "dd7878";
    pink = "ea76cb";
    mauve = "8839ef";
    red = "d20f39";
    maroon = "e64553";
    peach = "fe640b";
    yellow = "df8e1d";
    green = "40a02b";
    teal = "179299";
    sky = "04a5e5";
    sapphire = "209fb5";
    blue = "1e66f5";
    lavender = "7287fd";
    text = "4c4f69";
    subtext1 = "5c5f77";
    subtext0 = "6c6f85";
    overlay2 = "7c7f93";
    overlay1 = "8c8fa1";
    overlay0 = "9ca0b0";
    surface2 = "acb0be";
    surface1 = "bcc0cc";
    surface0 = "ccd0da";
    base = "eff1f5";
    mantle = "e6e9ef";
    crust = "dce0e8";
  };
in
{
  # Hyprland configuration
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor config (adjust for your setup)
      monitor = ",preferred,auto,1";
      
      # Autostart
      exec-once = [
        "waybar"
        "dunst"
        "nm-applet --indicator"
        "blueman-applet"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      # Input configuration
      input = {
        kb_layout = "fr";  # Change to your layout
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
        sensitivity = 0;
      };

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(${catppuccin.mauve}ee) rgba(${catppuccin.lavender}ee) 45deg";
        "col.inactive_border" = "rgba(${catppuccin.surface0}aa)";
        layout = "dwindle";
      };

      # Decorations
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      # Animations
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Keybindings
      "$mod" = "SUPER";
      bind = [
        # Apps
        "$mod, t, exec, kitty"
        "$mod, f, exec, firefox"
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, thunar"
        "$mod, V, togglefloating,"
        "$mod, D, exec, rofi -show drun"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"
        
        # Screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, Print, exec, grim - | wl-copy"
        
        # Lock screen
        "$mod, L, exec, hyprlock"
        
        # Move focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        
        # Switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        
        # Move windows to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        
        # Scroll through workspaces
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      # Media keys
      bindl = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
    };
  };

  # Waybar (status bar)
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];
        
        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
          };
        };
        
        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%A, %B %d, %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
        
        battery = {
          format = "{capacity}% {icon}";
          format-icons = ["" "" "" "" ""];
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
        };
        
        network = {
          format-wifi = "{essid} ";
          format-ethernet = "{ipaddr} ";
          format-disconnected = "Disconnected ⚠";
          tooltip-format = "{ifname}: {ipaddr}";
        };
        
        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "";
          format-icons = {
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };
        
        tray = {
          spacing = 10;
        };
      };
    };
    
    style = ''
      * {
        font-family: JetBrainsMono Nerd Font;
        font-size: 14px;
        border: none;
        border-radius: 0;
      }

      window#waybar {
        background-color: #${catppuccin.base};
        color: #${catppuccin.text};
      }

      #workspaces button {
        padding: 0 10px;
        color: #${catppuccin.text};
      }

      #workspaces button.active {
        background-color: #${catppuccin.mauve};
        color: #${catppuccin.base};
      }

      #workspaces button:hover {
        background-color: #${catppuccin.surface0};
      }

      #clock,
      #battery,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 10px;
        margin: 5px 0;
      }

      #battery.charging {
        color: #${catppuccin.green};
      }

      #battery.warning:not(.charging) {
        color: #${catppuccin.peach};
      }

      #battery.critical:not(.charging) {
        color: #${catppuccin.red};
      }
    '';
  };

  # Rofi (app launcher)
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "~/.config/rofi/catppuccin-latte.rasi";
  };

  # Rofi Catppuccin theme
  home.file.".config/rofi/catppuccin-latte.rasi".text = ''
    * {
      bg-col:  #${catppuccin.base};
      bg-col-light: #${catppuccin.base};
      border-col: #${catppuccin.base};
      selected-col: #${catppuccin.base};
      blue: #${catppuccin.mauve};
      fg-col: #${catppuccin.text};
      fg-col2: #${catppuccin.red};
      grey: #${catppuccin.overlay0};

      width: 600;
      font: "JetBrainsMono Nerd Font 14";
    }

    element-text, element-icon , mode-switcher {
      background-color: inherit;
      text-color:       inherit;
    }

    window {
      height: 360px;
      border: 3px;
      border-color: @border-col;
      background-color: @bg-col;
    }

    mainbox {
      background-color: @bg-col;
    }

    inputbar {
      children: [prompt,entry];
      background-color: @bg-col;
      border-radius: 5px;
      padding: 2px;
    }

    prompt {
      background-color: @blue;
      padding: 6px;
      text-color: @bg-col;
      border-radius: 3px;
      margin: 20px 0px 0px 20px;
    }

    textbox-prompt-colon {
      expand: false;
      str: ":";
    }

    entry {
      padding: 6px;
      margin: 20px 0px 0px 10px;
      text-color: @fg-col;
      background-color: @bg-col;
    }

    listview {
      border: 0px 0px 0px;
      padding: 6px 0px 0px;
      margin: 10px 0px 0px 20px;
      columns: 1;
      lines: 5;
      background-color: @bg-col;
    }

    element {
      padding: 5px;
      background-color: @bg-col;
      text-color: @fg-col;
    }

    element-icon {
      size: 25px;
    }

    element selected {
      background-color:  @selected-col;
      text-color: @fg-col2;
    }

    mode-switcher {
      spacing: 0;
    }

    button {
      padding: 10px;
      background-color: @bg-col-light;
      text-color: @grey;
      vertical-align: 0.5; 
      horizontal-align: 0.5;
    }

    button selected {
      background-color: @bg-col;
      text-color: @blue;
    }

    message {
      background-color: @bg-col-light;
      margin: 2px;
      padding: 2px;
      border-radius: 5px;
    }

    textbox {
      padding: 6px;
      margin: 20px 0px 0px 20px;
      text-color: @blue;
      background-color: @bg-col-light;
    }
  '';

  # Dunst (notifications)
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "30x50";
        origin = "top-right";
        transparency = 10;
        frame_color = "#${catppuccin.mauve}";
        font = "JetBrainsMono Nerd Font 10";
        corner_radius = 10;
      };
      
      urgency_low = {
        background = "#${catppuccin.base}";
        foreground = "#${catppuccin.text}";
        timeout = 5;
      };
      
      urgency_normal = {
        background = "#${catppuccin.base}";
        foreground = "#${catppuccin.text}";
        timeout = 10;
      };
      
      urgency_critical = {
        background = "#${catppuccin.base}";
        foreground = "#${catppuccin.red}";
        frame_color = "#${catppuccin.red}";
        timeout = 0;
      };
    };
  };

  # Hyprlock (lockscreen)
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(${catppuccin.text})";
          inner_color = "rgb(${catppuccin.surface0})";
          outer_color = "rgb(${catppuccin.mauve})";
          outline_thickness = 5;
          placeholder_text = "<span foreground='##${catppuccin.text}'>Password...</span>";
          shadow_passes = 2;
        }
      ];
    };
  };

  # Hypridle (auto-lock)
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 300; # 5min
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 600; # 10min
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 900; # 15min
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  # Additional packages
  home.packages = with pkgs; [
    cliphist
    playerctl
    hyprpicker
    wlogout
  ];
}
