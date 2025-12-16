{ config, pkgs, username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    # Kitty terminal configuration
    programs.kitty = {
      enable = true;
      font = {
        name = "Hack Nerd Font Mono";
        size = 11;
      };
      settings = {
        # Cursor
        cursor_shape = "block";
        cursor_blink_interval = 0;

        # Scrollback
        scrollback_lines = 10000;

        # Mouse
        mouse_hide_wait = "3.0";
        url_color = "#0087bd";
        url_style = "curly";

        # Window
        remember_window_size = true;
        initial_window_width = 640;
        initial_window_height = 400;
        window_padding_width = 4;
        hide_window_decorations = true;

        # Tab bar
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";

        # Performance
        repaint_delay = 10;
        input_delay = 3;
        sync_to_monitor = true;

        # Bell
        enable_audio_bell = false;
        visual_bell_duration = "0.0";

        # Clipboard
        clipboard_control = "write-clipboard write-primary";

        # Advanced
        allow_remote_control = true;
        shell_integration = "enabled";

        # Light Theme Colors (One Light inspired)
        foreground = "#383a42";
        background = "#fafafa";

        # Cursor colors
        cursor = "#526eff";
        cursor_text_color = "#fafafa";

        # Selection colors
        selection_foreground = "#fafafa";
        selection_background = "#526eff";

        # Black
        color0 = "#383a42";
        color8 = "#4f525e";

        # Red
        color1 = "#e45649";
        color9 = "#e06c75";

        # Green
        color2 = "#50a14f";
        color10 = "#98c379";

        # Yellow
        color3 = "#c18401";
        color11 = "#e5c07b";

        # Blue
        color4 = "#0184bc";
        color12 = "#61afef";

        # Magenta
        color5 = "#a626a4";
        color13 = "#c678dd";

        # Cyan
        color6 = "#0997b3";
        color14 = "#56b6c2";

        # White
        color7 = "#fafafa";
        color15 = "#ffffff";

        # Tab bar colors
        active_tab_foreground = "#383a42";
        active_tab_background = "#e5e5e6";
        inactive_tab_foreground = "#6c6f7e";
        inactive_tab_background = "#f0f0f1";
      };
    };
  };
}
