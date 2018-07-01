# Provides the latest version of this repo, which is useful since upstream
# nixpkgs only lets us fetch a specific commit. We enforce a few sanity checks,
# which are commented in the code below.
{ latestGit, repoSource, stable }:

with builtins;
with rec {
  src = latestGit {
    url    = "${repoSource}/nix-config.git";
    stable = {
      # Forces latest version to be used, even by a "stable" nix-config
      unsafeSkip = true;
    };
  };
};
assert stable || throw (toJSON {
         msg = ''
           Unstable nix-config doesn't provide latestNixConfig, since it's more
           likely to be misused than be of any help. Try the following:
            - You've already got an unstable nix-config, so use that directly.
            - Fetch a stable nix-config, and get latestNixConfig from there.
              This avoids problems like latestNixConfig getting renamed or
              removed in future versions.
            - Just use a stable version.
           We actually recommend taking nixpkgs and/or nix-config as a parameter
           of your build, and setting known-good, stable versions as defaults.
           That way, they can still be overridden when necessary (for example to
           test unstable versions in continuous integration).
         '';
       });
import "${src}/unstable.nix"
