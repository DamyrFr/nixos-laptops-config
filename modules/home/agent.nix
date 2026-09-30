{ pkgs, lib, ... }:

let
  # Skill sources shared by every agent: fetched once here, then linked into
  # each agent's own skills directory below.
  #
  # Base coding guidelines skill (Andrej Karpathy)
  # https://github.com/forrestchang/andrej-karpathy-skills
  baseSkill = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/forrestchang/andrej-karpathy-skills/main/skills/karpathy-guidelines/SKILL.md";
    sha256 = "19xfn9k03swvhwr1p0wl72sc3c1d57bxj1idwj5fk982rdacq8kf";
  };

  # Veille tech francophone skill (Camille Roux)
  # https://github.com/camilleroux/veille-techno
  veilleSkill = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/camilleroux/veille-techno/main/skills/veille/SKILL.md";
    sha256 = "1hxl3wnizp9asxyvcp22icfglzj6gv4w888dag3cqd7451gdd7gz";
  };

  veilleSources = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/camilleroux/veille-techno/main/skills/veille/sources.yml";
    sha256 = "1c6dxh1nakyv2ayxm0r8cpm354sqh56gl9v543mi8g5lm9skx6i4";
  };

  veilleFetchFeeds = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/camilleroux/veille-techno/main/skills/veille/fetch_feeds.py";
    sha256 = "0kb7fxpxgczajxmvx1xhdrlzs6mz5y5aik28ffbxh4q7z2r2g7a6";
  };

  # Dangerous infra-mutation commands denied by every agent's permission
  # gate (opencode AND pi, see pi-permissions.jsonc below). Declared once
  # here so the two gates cannot drift apart. `rtk ...` mirrors exist
  # because `rtk rewrite` prefixes these commands with `rtk `, which
  # would bypass rules anchored on the bare command name.
  denyCmds = [
    # kubectl mutations
    "kubectl create*"
    "kubectl apply*"
    "kubectl delete*"
    "kubectl patch*"
    "kubectl edit*"
    "kubectl replace*"
    "kubectl scale*"
    "kubectl set*"
    "kubectl label*"
    "kubectl annotate*"
    "kubectl taint*"
    "kubectl cordon*"
    "kubectl uncordon*"
    "kubectl drain*"
    "kubectl rollout restart*"
    "kubectl rollout undo*"
    "kubectl expose*"
    "kubectl autoscale*"
    "kubectl exec*"
    "kubectl cp*"

    # helm mutations (+ rtk rewrite mirror)
    "helm install*"
    "helm upgrade*"
    "helm uninstall*"
    "helm rollback*"
    "helm delete*"
    "rtk helm install*"
    "rtk helm upgrade*"
    "rtk helm uninstall*"
    "rtk helm rollback*"
    "rtk helm delete*"

    # flux mutations
    "flux delete*"
    "flux suspend*"
    "flux resume*"
    "flux reconcile*"

    # gcloud mutations (+ rtk rewrite mirror)
    "gcloud *create*"
    "gcloud *delete*"
    "gcloud *update*"
    "gcloud *set*"
    "gcloud *patch*"
    "gcloud *add*"
    "gcloud *remove*"
    "gcloud *deploy*"
    "gcloud *import*"
    "gcloud *undelete*"
    "gcloud *reset*"
    "gcloud *start*"
    "gcloud *stop*"
    "gcloud *restart*"
    "gcloud *promote*"
    "gcloud *rollback*"
    "rtk gcloud *create*"
    "rtk gcloud *delete*"
    "rtk gcloud *update*"
    "rtk gcloud *set*"
    "rtk gcloud *patch*"
    "rtk gcloud *add*"
    "rtk gcloud *remove*"
    "rtk gcloud *deploy*"
    "rtk gcloud *import*"
    "rtk gcloud *undelete*"
    "rtk gcloud *reset*"
    "rtk gcloud *start*"
    "rtk gcloud *stop*"
    "rtk gcloud *restart*"
    "rtk gcloud *promote*"
    "rtk gcloud *rollback*"

    # aws mutations (+ rtk rewrite mirror)
    "aws *create*"
    "aws *delete*"
    "aws *put*"
    "aws *update*"
    "aws *modify*"
    "aws *terminate*"
    "aws *remove*"
    "aws *attach*"
    "aws *detach*"
    "aws *register*"
    "aws *deregister*"
    "aws *revoke*"
    "aws *authorize*"
    "aws *reboot*"
    "aws *run-instances*"
    "aws *stop-instances*"
    "aws *start-instances*"
    "aws s3 rm*"
    "aws s3 mv*"
    "aws s3 cp*"
    "aws s3 sync*"
    "aws s3 rb*"
    "aws s3api put-object*"
    "aws s3api delete-object*"
    "rtk aws *create*"
    "rtk aws *delete*"
    "rtk aws *put*"
    "rtk aws *update*"
    "rtk aws *modify*"
    "rtk aws *terminate*"
    "rtk aws *remove*"
    "rtk aws *attach*"
    "rtk aws *detach*"
    "rtk aws *register*"
    "rtk aws *deregister*"
    "rtk aws *revoke*"
    "rtk aws *authorize*"
    "rtk aws *reboot*"
    "rtk aws *run-instances*"
    "rtk aws *stop-instances*"
    "rtk aws *start-instances*"
    "rtk aws s3 rm*"
    "rtk aws s3 mv*"
    "rtk aws s3 cp*"
    "rtk aws s3 sync*"
    "rtk aws s3 rb*"
    "rtk aws s3api put-object*"
    "rtk aws s3api delete-object*"

    # terraform / tofu mutations
    "terraform apply*"
    "terraform destroy*"
    "terraform import*"
    "terraform state rm*"
    "terraform state mv*"
    "terraform state push*"
    "terraform taint*"
    "terraform untaint*"
    "terraform force-unlock*"
    "tofu apply*"
    "tofu destroy*"
    "tofu import*"
    "tofu state rm*"
    "tofu state mv*"
    "tofu state push*"
    "tofu taint*"
    "tofu untaint*"
    "tofu force-unlock*"
  ];
in
{
  home.packages = with pkgs; [
    claude-code
    pi-coding-agent
    # pi shells out to `npm` to install the Pi packages declared below; its
    # wrapper carries no node toolchain of its own.
    nodejs
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
      } // lib.genAttrs denyCmds (_: "deny");
    };
  };

  home.activation.rtkInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.rtk}/bin/rtk init -g
    $DRY_RUN_CMD ${pkgs.rtk}/bin/rtk init -g --opencode
  '';

  # ~/.pi/agent/settings.json is a read-only /nix/store symlink, so `pi
  # install` cannot record packages there. This reconciles the declared
  # `packages` into ~/.pi/agent/npm/ instead. Needs network, so never let it
  # fail an activation.
  home.activation.piPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD env PATH="${pkgs.nodejs}/bin:$PATH" \
      ${pkgs.pi-coding-agent}/bin/pi update --extensions || true
  '';

  # Pi coding agent. No home-manager module exists for it, so the agent
  # directory (~/.pi/agent, overridable with PI_CODING_AGENT_DIR) is written
  # by hand. `packages` declares npm Pi packages; pi resolves them into
  # ~/.pi/agent/npm/node_modules (see the piPackages activation above).
  home.file.".pi/agent/settings.json".source =
    (pkgs.formats.json { }).generate "pi-settings.json" {
      theme = "tokyonight-day";
      packages = [
        # RTK command rewriting + output compaction, the Pi-native equivalent
        # of the rtk.ts plugin. That is why `rtk init --agent pi` is not run:
        # it would install a second rewriter alongside this one.
        "npm:pi-rtk-optimizer"
        "npm:pi-subagents"
        "npm:pi-mcp-adapter"
        "npm:pi-web-access"
        "npm:pi-goal-x"
        "npm:context-mode"
        "npm:pi-permission-system"
      ];
    };

  # Pi permission policy (npm:pi-permission-system). Mirrors the opencode
  # permission gate: bash asks by default with the same denyCmds, file
  # mutation (write/edit) asks, read-only tools allowed, paths outside the
  # session cwd ask. Generated as plain JSON (valid JSONC) via the same
  # formats.json mechanism as settings.json above.
  #
  # Ordering note: pi-permission-system resolves bash rules with
  # last-matching-rule-wins. Nix serializes attrset keys alphabetically and
  # "*" (ASCII 0x2A) sorts before every letter, so the broad fallback always
  # lands before the specific deny rules. Order between deny rules is
  # irrelevant (same verdict). If a specific `allow` override is ever added
  # for a command, it sorts after "*" and wins, which is the intended
  # direction. Do not add a fallback pattern that starts with a character
  # sorting after one of the deny patterns.
  home.file.".pi/agent/pi-permissions.jsonc".source =
    (pkgs.formats.json { }).generate "pi-permissions.jsonc" {
      defaultPolicy = {
        tools = "ask";
        bash = "ask";
        mcp = "ask";
        skills = "ask";
        special = "ask";
      };
      tools = {
        # Read-only tools: allowed (opencode does not gate reads either).
        read = "allow";
        grep = "allow";
        find = "allow";
        ls = "allow";
        # File mutations ask (opencode's edit default).
        write = "ask";
        edit = "ask";
      };
      # Loading/reading skills is not a mutation.
      skills."*" = "allow";
      # Path protection: paths outside the session cwd ask.
      special.external_directory = "ask";
      # Same command gate as opencode (denyCmds from the let block above).
      bash = { "*" = "ask"; } // lib.genAttrs denyCmds (_: "deny");
    };

  # White/clean theme matching the neovim colorscheme (tokyonight-day). The
  # file name must equal the theme's `name` or pi will not hot-reload it.
  home.file.".pi/agent/themes/tokyonight-day.json".source =
    ./pi/tokyonight-day.json;

  home.file.".pi/agent/skills/base/SKILL.md".source = baseSkill;
  home.file.".pi/agent/skills/veille/SKILL.md".source = veilleSkill;
  home.file.".pi/agent/skills/veille/sources.yml".source = veilleSources;
  home.file.".pi/agent/skills/veille/fetch_feeds.py".source = veilleFetchFeeds;

  home.file.".claude/skills/base/SKILL.md".source = baseSkill;
  home.file.".claude/skills/veille/SKILL.md".source = veilleSkill;
  home.file.".claude/skills/veille/sources.yml".source = veilleSources;
  home.file.".claude/skills/veille/fetch_feeds.py".source = veilleFetchFeeds;

  home.file.".config/opencode/skills/base/SKILL.md".source = baseSkill;
}
