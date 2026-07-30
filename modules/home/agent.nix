{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    claude-code
    rtk
  ];

  # OpenCode + plugins. The module writes ~/.config/opencode/opencode.json
  # (auto-adds $schema). `plugin` lists npm plugins opencode fetches into
  # node_modules/ on startup. plugins/rtk.ts stays runtime-managed by rtk.
  # extraPackages provides the Linux runtime deps opencode-notifier needs:
  # libnotify (notify-send) + alsa-utils (aplay) for sounds.
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    extraPackages = with pkgs; [ libnotify alsa-utils ];
    settings = {
      plugin = [
        "opencode-mem"
        "@mohak34/opencode-notifier@latest"
      ];
      permission.bash = {
        "*" = "ask";

        "kubectl create*" = "deny";
        "kubectl apply*" = "deny";
        "kubectl delete*" = "deny";
        "kubectl patch*" = "deny";
        "kubectl edit*" = "deny";
        "kubectl replace*" = "deny";
        "kubectl scale*" = "deny";
        "kubectl set*" = "deny";
        "kubectl label*" = "deny";
        "kubectl annotate*" = "deny";
        "kubectl taint*" = "deny";
        "kubectl cordon*" = "deny";
        "kubectl uncordon*" = "deny";
        "kubectl drain*" = "deny";
        "kubectl rollout restart*" = "deny";
        "kubectl rollout undo*" = "deny";
        "kubectl expose*" = "deny";
        "kubectl autoscale*" = "deny";
        "kubectl exec*" = "deny";
        "kubectl cp*" = "deny";

        "helm install*" = "deny";
        "helm upgrade*" = "deny";
        "helm uninstall*" = "deny";
        "helm rollback*" = "deny";
        "helm delete*" = "deny";

        "flux delete*" = "deny";
        "flux suspend*" = "deny";
        "flux resume*" = "deny";
        "flux reconcile*" = "deny";

        "gcloud *create*" = "deny";
        "gcloud *delete*" = "deny";
        "gcloud *update*" = "deny";
        "gcloud *set*" = "deny";
        "gcloud *patch*" = "deny";
        "gcloud *add*" = "deny";
        "gcloud *remove*" = "deny";
        "gcloud *deploy*" = "deny";
        "gcloud *import*" = "deny";
        "gcloud *undelete*" = "deny";
        "gcloud *reset*" = "deny";
        "gcloud *start*" = "deny";
        "gcloud *stop*" = "deny";
        "gcloud *restart*" = "deny";
        "gcloud *promote*" = "deny";
        "gcloud *rollback*" = "deny";

        "aws *create*" = "deny";
        "aws *delete*" = "deny";
        "aws *put*" = "deny";
        "aws *update*" = "deny";
        "aws *modify*" = "deny";
        "aws *terminate*" = "deny";
        "aws *remove*" = "deny";
        "aws *attach*" = "deny";
        "aws *detach*" = "deny";
        "aws *register*" = "deny";
        "aws *deregister*" = "deny";
        "aws *revoke*" = "deny";
        "aws *authorize*" = "deny";
        "aws *reboot*" = "deny";
        "aws *run-instances*" = "deny";
        "aws *stop-instances*" = "deny";
        "aws *start-instances*" = "deny";
        "aws s3 rm*" = "deny";
        "aws s3 mv*" = "deny";
        "aws s3 cp*" = "deny";
        "aws s3 sync*" = "deny";
        "aws s3 rb*" = "deny";
        "aws s3api put-object*" = "deny";
        "aws s3api delete-object*" = "deny";

        "terraform apply*" = "deny";
        "terraform destroy*" = "deny";
        "terraform import*" = "deny";
        "terraform state rm*" = "deny";
        "terraform state mv*" = "deny";
        "terraform state push*" = "deny";
        "terraform taint*" = "deny";
        "terraform untaint*" = "deny";
        "terraform force-unlock*" = "deny";

        "tofu apply*" = "deny";
        "tofu destroy*" = "deny";
        "tofu import*" = "deny";
        "tofu state rm*" = "deny";
        "tofu state mv*" = "deny";
        "tofu state push*" = "deny";
        "tofu taint*" = "deny";
        "tofu untaint*" = "deny";
        "tofu force-unlock*" = "deny";
      };
    };
  };

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
