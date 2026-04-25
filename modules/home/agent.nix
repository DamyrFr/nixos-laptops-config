{ pkgs, ... }:

{
  home.packages = with pkgs; [
    claude-code
    opencode
    rtk
  ];

  # Base coding guidelines skill (Andrej Karpathy)
  # https://github.com/forrestchang/andrej-karpathy-skills
  home.file.".claude/skills/base/SKILL.md".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/skills/karpathy-guidelines/SKILL.md";
    sha256 = "19xfn9k03swvhwr1p0wl72sc3c1d57bxj1idwj5fk982rdacq8kf";
  };

  home.file.".config/opencode/skills/base/SKILL.md".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/skills/karpathy-guidelines/SKILL.md";
    sha256 = "19xfn9k03swvhwr1p0wl72sc3c1d57bxj1idwj5fk982rdacq8kf";
  };
}
