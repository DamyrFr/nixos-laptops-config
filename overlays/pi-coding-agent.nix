# nixpkgs pi-coding-agent 1.5.0 packaging bug fix (local overlay).
#
# Since 1.5.0, @earendil-works/pi-ai depends on @earendil-works/pi-schema at
# runtime (dist/providers/*.js import it). In the monorepo that dep is a
# workspace symlink (packages/schema), but the nixpkgs expression's postInstall
# copies only a hardcoded list of workspace deps into node_modules and then
# deletes all remaining */packages/* symlinks — pi-schema is not in the list,
# so it is deleted and never restored. Anything importing pi-ai from the
# unbundled store dist then fails to resolve "@earendil-works/pi-schema"
# (breaks pi-subagents delegation, runner startup, etc.).
#
# pi-schema has no runtime dependencies (its package.json only lists
# devDependencies), so a plain copy of the built workspace is enough.
#
# Drop this overlay once nixpkgs' pkgs/by-name/pi/pi-coding-agent includes
# @earendil-works/pi-schema:packages/schema in its postInstall copy list.
final: prev: {
  pi-coding-agent = prev.pi-coding-agent.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      local nm="$out/lib/node_modules/pi-monorepo/node_modules"
      rm -rf "$nm/@earendil-works/pi-schema"
      cp -r packages/schema "$nm/@earendil-works/pi-schema"
    '';
  });
}
