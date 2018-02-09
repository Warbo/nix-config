{ callPackage, nothing, repo, runCommand }:

with rec {
  suffix = "pkgs/misc/themes/clearlooks-phenix";

  havePath = import (runCommand "have-clearlooks-phenix.nix"
    { inherit repo suffix; }
    ''
      if [[ -e "$repo/$suffix" ]]
      then
        echo true  > "$out"
      else
        echo false > "$out"
      fi
    '');

  pkg = callPackage "${repo}/${suffix}" {};
};

if havePath then pkg else nothing
