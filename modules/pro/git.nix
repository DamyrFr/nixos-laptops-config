{ lib, ... }:

{
  # Pro machine: default Git identity is tw (git.waays.fr).
  # The includeIf rules defined in modules/core still apply, so pushing to a
  # github.com remote will use DamyR and a git.waays.fr remote will use tw;
  # this only changes the fallback identity when no remote rule matches.
  programs.git.config.user = {
    name = lib.mkForce "tw";
    email = lib.mkForce "tg@waays.fr";
  };
}
