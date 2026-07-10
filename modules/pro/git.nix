{ lib, pkgs, ... }:

{
  # Pro machine: default Git identity is tw (git.waays.fr).
  # The includeIf rules defined in modules/core still apply, so pushing to a
  # github.com remote will use DamyR and a git.waays.fr remote will use tw;
  # this only changes the fallback identity when no remote rule matches.
  #
  # We override the unconditional `[include].path` (not `[user]`), because an
  # inline `[user]` section would be rendered after the `[includeIf]` blocks
  # and clobber the per-remote identities (Git is last-value-wins).
  programs.git.config.include.path = lib.mkForce "${
    pkgs.writeText "git-identity-tw-default" ''
      [user]
      	name = tw
      	email = tg@waays.fr
    ''
  }";
}
