{ isBroken, lib, perlPackages, super, system, withDeps }:

# Remove once the patch has trickled down.
# See https://github.com/NixOS/nixpkgs/pull/32001
with rec {
  pv = perlPackages.ParamsValidate;

  fixed = super.hydra.override {
    perlPackages = perlPackages.override {
      overrides = {
        ParamsValidate = pv.overrideAttrs (old: {
          perlPreHook = "export LD=$CC";
        });
      };
    };
  };

  # Next we disable 'restricted-eval' mode by patching the source
  unrestricted = lib.overrideDerivation fixed (old: {
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
withDeps (if system == "i686-linux"
             then [ (isBroken pv) ]
             else [])
         unrestricted
