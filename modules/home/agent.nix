{ config, pkgs, lib, ... }:

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

  # Bash commands denied by every agent's permission gate (opencode and pi).
  # Rules match the whole command string with `*` globs, last match wins.
  #
  # `denyVerbs` is expanded per tool into `*<tool>* <verb> *`, `*<tool>* <verb>`
  # and `*<tool>* <verb>-*`:
  #  - the leading `*` covers `rtk ` (added by `rtk rewrite`), env vars,
  #    `cd x &&`, `sudo`;
  #  - `*` after the tool covers flags before the verb (`kubectl -n x delete`);
  #  - the space before the verb makes it a whole word, so `--output` does not
  #    match `put` and `addresses` does not match `add`.
  denyVerbs =
    let
      terraformVerbs = [
        "apply" "destroy" "import" "taint" "untaint" "force-unlock"
        "state rm" "state mv" "state push"
      ];
    in
    {
      kubectl = [
        "create" "apply" "delete" "patch" "edit" "replace" "scale" "set"
        "label" "annotate" "taint" "cordon" "uncordon" "drain" "expose"
        "autoscale" "exec" "cp" "run" "debug" "attach" "port-forward"
        "rollout restart" "rollout undo" "rollout pause" "rollout resume"
        "config use-context" "config delete-context"
      ];
      helm = [ "install" "upgrade" "uninstall" "rollback" "delete" ];
      flux = [ "create" "delete" "suspend" "resume" "reconcile" "bootstrap" "uninstall" ];
      gcloud = [
        "create" "delete" "update" "set" "patch" "add" "remove" "deploy" "import"
        "undelete" "reset" "start" "stop" "restart" "promote" "rollback"
      ];
      aws = [
        "create" "delete" "put" "update" "modify" "terminate" "remove" "attach"
        "detach" "register" "deregister" "revoke" "authorize" "reboot"
        "run-instances" "stop-instances" "start-instances"
        "s3 rm" "s3 mv" "s3 cp" "s3 sync" "s3 rb"
      ];
      terraform = terraformVerbs;
      tofu = terraformVerbs;
      git = [ "reset --hard" "clean -f" "clean -fd" "clean -fdx" "clean -xdf" ];
      gh = [
        "pr merge" "repo delete" "repo archive" "release delete"
        "secret set" "secret delete" "variable set" "variable delete"
      ];
      npm = [ "publish" "unpublish" "deprecate" ];
      pnpm = [ "publish" ];
      docker = [
        "system prune" "volume prune" "image prune" "container prune"
        "builder prune" "volume rm"
      ];
    };

  # Patterns that do not fit the tool/verb shape.
  denyExtra =
    [
      # Passwordless sudo for wheel: agents never escalate.
      "sudo *"
      "* sudo *"
      "doas *"
      "* doas *"
      # History rewrites on shared remotes.
      "*git* push *--force*"
      "*git* push * -f"
      "*git* push * -f *"
      "*git* push -f*"
    ]
    ++ lib.concatMap
      (flags:
        lib.concatMap (target: [ "*rm ${flags} ${target}" "*rm ${flags} ${target} *" ])
          [ "/" "~" "~/" "$HOME" "$HOME/" "\${HOME}" ])
      [ "-rf" "-fr" "-Rf" "-rF" ];

  denyCmds =
    lib.concatLists (
      lib.mapAttrsToList
        (tool: verbs:
          lib.concatMap (v: [ "*${tool}* ${v} *" "*${tool}* ${v}" "*${tool}* ${v}-*" ]) verbs)
        denyVerbs
    )
    ++ denyExtra;

  # Shared bash gate: ask by default, deny the list above. Nix sorts keys and
  # "*" sorts first, so the fallback always comes before the deny rules.
  bashPolicy = { "*" = "ask"; } // lib.genAttrs denyCmds (_: "deny");

  # Evaluate a command against bashPolicy like the agents do (glob, whole
  # string, last match in key order wins). Used by the assertions below.
  globToRegex = glob: lib.concatMapStringsSep ".*" lib.escapeRegex (lib.splitString "*" glob);
  bashVerdict = cmd:
    lib.foldl'
      (acc: pat: if builtins.match (globToRegex pat) cmd != null then bashPolicy.${pat} else acc)
      "none"
      (builtins.attrNames bashPolicy);

  bashPolicyTests = {
    ask = [
      "git status"
      "rtk git status"
      "git push origin main"
      "kubectl get pods -A"
      "rtk kubectl get pods"
      "kubectl -n prod logs deploy/api"
      "helm list -A"
      "helm list --uninstalled"
      "flux get kustomizations"
      "terraform plan"
      "rtk terraform plan"
      "aws ec2 describe-instances --output json"
      "rtk aws sts get-caller-identity --output json"
      "aws s3 ls s3://bucket --output text"
      "gcloud compute addresses list"
      "gcloud container clusters list --format=json"
      "rm -rf build"
      "rm -rf /tmp/x"
      "nix flake check"
    ];
    deny = [
      "kubectl apply -f x.yaml"
      "rtk kubectl apply -f x.yaml"
      "kubectl -n prod delete pod x"
      "kubectl --context prod apply -f x"
      "KUBECONFIG=~/.kube/prod kubectl delete ns x"
      "kubectl rollout restart deploy/api"
      "helm -n prod uninstall x"
      "rtk helm upgrade --install x ./chart"
      "flux reconcile ks apps"
      "cd infra && terraform apply"
      "terraform -chdir=infra apply -auto-approve"
      "rtk terraform destroy"
      "tofu state rm aws_s3_bucket.x"
      "aws s3 rm s3://bucket/key"
      "aws ec2 terminate-instances --instance-ids i-1"
      "rtk aws s3api put-object --bucket b --key k"
      "gcloud compute instances delete vm-1"
      "gcloud projects add-iam-policy-binding p --member x"
      "sudo nixos-rebuild switch"
      "ls && sudo rm x"
      "git push --force origin main"
      "git push origin main --force-with-lease"
      "rtk git push -f"
      "git reset --hard HEAD~1"
      "rm -rf ~"
      "rm -rf /"
      "rm -fr $HOME/"
      "gh pr merge 12 --squash"
      "npm publish"
      "docker system prune -af"
    ];
  };

  bashPolicyFailures = lib.concatLists (
    lib.mapAttrsToList
      (expect: cmds:
        map (c: "${expect} expected, got ${bashVerdict c}: ${c}")
          (lib.filter (c: bashVerdict c != expect) cmds))
      bashPolicyTests
  );

  # Secrets no agent tool may read or write (Pi path rules, see below).
  secretPaths = map (p: "${config.home.homeDirectory}/${p}") [
    ".ssh/*"
    ".gnupg/*"
    ".aws/*"
    ".kube/*"
    ".config/gcloud/*"
    ".docker/config.json"
    ".pi/agent/auth.json"
    ".local/share/opencode/auth.json"
    ".claude/.credentials.json"
  ];
in
{
  home.packages = with pkgs; [
    claude-code
    rtk
  ];

  assertions = [
    {
      assertion = bashPolicyFailures == [ ];
      message = "agent bash policy tests failed:\n" + lib.concatStringsSep "\n" bashPolicyFailures;
    }
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
      # Same gate as pi: edits ask, paths outside the project ask.
      permission = {
        edit = "ask";
        external_directory = "ask";
        bash = bashPolicy;
      };
    };
  };

  home.activation.rtkInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.rtk}/bin/rtk init -g
    $DRY_RUN_CMD ${pkgs.rtk}/bin/rtk init -g --opencode
  '';

  # Pi coding agent (home-manager module). settings.json is a read-only
  # store symlink, so `pi install` / `pi config` / `/settings` cannot persist:
  # edit here. `packages` are pinned; bump a version and rebuild to update.
  programs.pi-coding-agent = {
    enable = true;
    # npm for Pi package installs (pi's wrapper has no node toolchain).
    extraPackages = [ pkgs.nodejs ];
    settings = {
      "$schema" = "https://pi.dev/schemas/settings.schema.json";

      defaultProvider = "openrouter";
      defaultModel = "z-ai/glm-5.3";
      enabledModels = [
        "openrouter/z-ai/glm-5.3"
        "anthropic/claude-sonnet-5-5"
        "anthropic/claude-haiku-5-5"
        "anthropic/claude-fable-5-1"
      ];
      showCacheMissNotices = true;

      defaultProjectTrust = "ask";
      enableInstallTelemetry = false;

      theme = "tokyonight-day";
      quietStartup = "header";
      collapseChangelog = true;
      terminal.showTerminalProgress = true;

      packages = [
        # Pi-native RTK rewriter; replaces `rtk init --agent pi`.
        "npm:pi-rtk-optimizer@0.9.0"
        "npm:pi-permission-system@0.8.0"
        "npm:pi-subagents@0.79.1"
        "npm:pi-web-access@0.42.0"
        "npm:pi-goal-x@0.32.3"
        "npm:pi-btw@0.8.0"
        "npm:context-mode@1.0.169"
      ];
    };
  };

  # Reconciles the declared `packages` into ~/.pi/agent/npm/. Needs network,
  # so never let it fail an activation.
  home.activation.piPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD env PATH="${pkgs.nodejs}/bin:$PATH" \
      ${pkgs.pi-coding-agent}/bin/pi update --extensions || true
  '';

  # Pi permission policy (npm:pi-permission-system), mirrors the opencode gate.
  # Bash rules are last-match-wins and Nix sorts keys, so "*" always lands
  # before the deny rules. Never add a fallback that sorts after them.
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
        # File mutations ask (same as opencode's permission.edit).
        write = "ask";
        edit = "ask";
        tool_search = "allow";
        # codemode scripts can call every other tool, including MCP ones.
        codemode = "ask";
        # .env files ask even inside the project ("read" < "read:*" in key
        # order, so these win over the plain allow).
        "read:*/.env" = "ask";
        "read:*/.env.*" = "ask";
        "grep:*/.env" = "ask";
        "grep:*/.env.*" = "ask";
      }
      // lib.listToAttrs (
        lib.concatMap
          (path: map (tool: lib.nameValuePair "${tool}:${path}" "deny") [ "read" "grep" "find" "ls" "edit" "write" ])
          secretPaths
      );
      # Loading/reading skills is not a mutation.
      skills."*" = "allow";
      # Path protection: paths outside the session cwd ask.
      special.external_directory = "ask";
      # Same command gate as opencode (denyCmds from the let block above).
      bash = bashPolicy;
    };

  # White/clean theme matching the neovim colorscheme (tokyonight-day). The
  # file name must equal the theme's `name` or pi will not hot-reload it.
  home.file.".pi/agent/themes/tokyonight-day.json".source =
    ./pi/tokyonight-day.json;

  # Custom footer + themed prompt editor (/footer toggles it).
  home.file.".pi/agent/extensions/status-footer.ts".source =
    ./pi/status-footer.ts;

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
