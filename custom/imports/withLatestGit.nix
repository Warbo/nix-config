# Use latestGit as src for a derivation, then store the commit ID the derivation
{ url, ref ? "HEAD" }: f:
let pkgs    = import <nixpkgs> {};
    source  = pkgs.latestGit { inherit url ref; };
    result  = f source;
    hUrl    = builtins.hashString "sha256" url;
    hRef    = builtins.hashString "sha256" ref;
    rev     = source.rev;
 in pkgs.lib.overrideDerivation result (old: {
      setupHook = pkgs.substituteAll {
        src = ./nixGitRefs.sh;
        key = "${hUrl}_${hRef}";
        val = rev;
      };
    })
