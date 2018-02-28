{ callPackage, fetchFromGitHub, isBroken, lib, moreutils, perlPackages, replace,
  super, system, withDeps }:

# Hydra's pretty broken. Try to keep track of the problems using isBroken, so we
# will be notified when anything gets fixed.
with rec {

  # There's a known bug with pv on i686
  # See https://github.com/NixOS/nixpkgs/pull/32001
  pv = perlPackages.ParamsValidate;

  i686Fix = hydra:
    with {
      fixed = withDeps [ (isBroken pv) ] (hydra.override {
        perlPackages = perlPackages.override {
          overrides = {
            ParamsValidate = pv.overrideAttrs (old: {
              perlPreHook = "export LD=$CC";
            });
          };
        };
      });
    };
    if system == "i686-linux" then fixed else hydra;

  # newHydra should have working dependencies, but is itself broken
  newHydra = i686Fix super.hydra;

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

  oldHydra = i686Fix (callPackage "${src}/pkgs/development/tools/misc/hydra"
                                  deps);

  workingHydra = withDeps (if system == "i686-linux"
                              then [ (isBroken newHydra) ]
                              else [                     ])
                          oldHydra;

  # We also disable 'restricted-eval' mode by patching the source

  unrestricted = lib.overrideDerivation workingHydra (old: {
    preFixup = ''
      while read -r F
      do
        "${replace}/bin/replace" "$TMPDIR" "$out" -- "$F"
      done < <(find "$out" -type f)
    '';

    patchPhase = ''
      echo "Removing aws-sdk-cpp, which won't build on 32bit" 1>&2
      patch -u -p1   -i "${./hydraSansS3.patch}"
      grep 'Only in ' < "${./hydraSansS3.patch}" |
        sed -e 's@Only in hydra-orig/@@g'        |
        sed -e 's@: @/@g'                        |
        while read -r F
        do
          rm -vf "$F"
        done

      if [[ -e src/hydra-queue-runner/s3-binary-cache-store.cc ]]
      then
        echo "Patch failed to delete things" 1>&2
        exit 1
      fi


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

      echo "Adding in missing math library" 1>&2
      for F in src/hydra-eval-jobs/*.cc src/hydra-queue-runner/*.cc
      do
        cat <(echo "#include <math.h>") "$F" | "${moreutils}/bin/sponge" "$F"
      done
    '';
  });
};

unrestricted
