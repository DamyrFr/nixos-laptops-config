{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    claude-code
    opencode
    rtk
  ];

  home.activation.rtkInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.rtk}/bin/rtk init -g
    $DRY_RUN_CMD ${pkgs.rtk}/bin/rtk init -g --opencode
  '';

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

  # Veille tech francophone skill (Camille Roux)
  # https://github.com/camilleroux/veille-techno
  home.file.".claude/skills/veille/SKILL.md".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/camilleroux/veille-techno/main/skills/veille/SKILL.md";
    sha256 = "1hxl3wnizp9asxyvcp22icfglzj6gv4w888dag3cqd7451gdd7gz";
  };

  home.file.".claude/skills/veille/sources.yml".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/camilleroux/veille-techno/main/skills/veille/sources.yml";
    sha256 = "1c6dxh1nakyv2ayxm0r8cpm354sqh56gl9v543mi8g5lm9skx6i4";
  };

  home.file.".claude/skills/veille/fetch_feeds.py".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/camilleroux/veille-techno/main/skills/veille/fetch_feeds.py";
    sha256 = "0kb7fxpxgczajxmvx1xhdrlzs6mz5y5aik28ffbxh4q7z2r2g7a6";
  };
}
