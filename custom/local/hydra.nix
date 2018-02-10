{ callPackage, fetchFromGitHub, isBroken, lib, perlPackages, super, system,
  withDeps }:

# Hydra's pretty broken. Try to keep track of the problems using isBroken, so we
# will be notified when anything gets fixed.
with rec {

  # There's a known bug with pv on i686
  # See https://github.com/NixOS/nixpkgs/pull/32001
  pv = perlPackages.ParamsValidate;

  i686Fix = hydra: withDeps [ (isBroken pv) ] (hydra.override {
    perlPackages = perlPackages.override {
      overrides = {
        ParamsValidate = pv.overrideAttrs (old: {
          perlPreHook = "export LD=$CC";
        });
      };
    };
  });

  # newHydra should have working dependencies, but is itself broken
  newHydra = if system == "i686-linux"
                then i686Fix super.hydra
                else super.hydra;

  # Use known-good old version

  src = fetchFromGitHub  {
    owner  = "NixOS";
    repo   = "nixpkgs-channels";
    rev    = "3badad8";
    sha256 = "0izfn9pg6jjc945pmfh20akzjpj7g95frz0rfgw2kn2g8drpfjd0";
  };

  deps = {
    inherit (callPackage "${src}/pkgs/servers/sql/postgresql"       {})
      postgresql92;
    inherit (callPackage "${src}/pkgs/tools/package-management/nix" {})
      nixUnstable;
  };

  oldHydra = i686Fix
    (callPackage "${src}/pkgs/development/tools/misc/hydra" deps);

  # We also disable 'restricted-eval' mode by patching the source

  unrestricted = lib.overrideDerivation oldHydra (old: {
    patchPhase = ''
      F='src/hydra-eval-jobs/hydra-eval-jobs.cc'
      echo "Patching '$F' to switch off restricted mode" 1>&2
      [[ -f "$F" ]] || {
        echo "File '$F' not found, aborting" 1>&2
        exit 2
      }

      function patterns {
        echo 'settings.set("restrict-eval", "true");'
        echo 'settings.restrictEval = true;'
      }

      PAT=""
      while read -r CANDIDATE
      do
        if grep -F "$CANDIDATE" < "$F" > /dev/null
        then
          PAT="$CANDIDATE"
        fi
      done < <(patterns)

      [[ -n "$PAT" ]] || {
        echo "Couldn't find where restricted mode is enabled, aborting" 1>&2
        exit 3
      }

      NEW=$(echo "$PAT" | sed -e 's/true/false/g')
      sed -e "s/$PAT/$NEW/g" -i "$F"

      while read -r CANDIDATE
      do
        if grep -F "$CANDIDATE" < "$F" > /dev/null
        then
          echo "String '$CANDIDATE' still in '$F', aborting" 1>&2
          exit 4
        fi
      done < <(patterns)
      echo "Restricted mode disabled" 1>&2
    '';
  });
};

withDeps [ (isBroken newHydra) ] unrestricted
