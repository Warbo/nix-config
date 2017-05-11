{ buildEnv, cabal-install, cabal2nix, hackageDb, haskellPackages, haskellTinc,
  runCommand, withNix, writeScript, runCabal2nix }:

with builtins;
with rec {
  defHPkg = haskellPackages;

  nixMangler = runCommand "nix-mangler"
    {
      buildInputs = [ (defHPkg.ghcWithPackages (p: [ p.hnix ])) ];
      raw = writeScript "Main.hs" ''
        module Main

        import Nix.Parser

        transformExpr = id

        transformStr = show . transformExpr . succ . parseNixString
          where succ (Success x) = x
                succ (Failure e) = error (show e)

        main = interact transformStr
      '';
    }
    ''
      mkdir -p "$out/bin"
      ghc "$raw" -o "$out/bin/nixMangler"
    '';

  tincify = args:
    assert isAttrs args || abort "tincify args should be attrs";
    assert args ? src   || abort "tincify args should contain src";
    with rec {
      inherit (args) src;
      name            = args.name            or "pkg";
      haskellPackages = args.haskellPackages or defHPkg;
      pkgs            = args.pkgs            or import <nixpkgs> {};
      extras          = args.extras          or [];

      # By default, tinc runs Cabal in a Nix shell with the following available:
      #
      #   haskellPackages.ghcWithPackages (p: [ p.cabal-install ])'
      #
      # This can be fiddled a bit using TINC_NIX_RESOLVER, but overall we're
      # stuck using a Haskell package set that's available globally with a
      # particular attribute path. We don't want that; we want to use the
      # Haskell package set we've been given (haskellPackages), which might not
      # be available globally.
      #
      # To make tinc use this version, we rely on the fact it's only using
      # cabal-install, as above. We build that derivation, using our Haskell
      # package set, write it to disk, then set NIX_PATH such that tinc's
      # nix-shell invocation uses the derivation we built. Phew!
      toUse = buildEnv {
        name  = "tinc-env";
        paths = [ (haskellPackages.ghcWithPackages (p:
                    map (name: p."${name}") ([ "cabal-install" ] ++ extras))) ];
      };

      env = runCommand "tinc-env"
        {
          expr = writeScript "force-tinc-env.nix" ''
            _:
              import <real> {} // {
              haskellPackages = {
                ghcWithPackages = _:
                  ${toUse};
              };
            }
          '';
        }
        ''
          mkdir -p "$out/pkgs/build-support/fetchurl"
          cp "$expr" "$out/default.nix"
          cp "${<nixpkgs/pkgs/build-support/fetchurl/mirrors.nix>}" \
             "$out/pkgs/build-support/fetchurl/mirrors.nix"
        '';

      NIX_PATH = concatStringsSep ":" [
        "nixpkgs=${env}"
        "real=${(head (filter (p: p.prefix == "nixpkgs")
                              nixPath)).path}"
      ];

      defs = runCommand "tinc-of-${name}"
               (withNix {
                 inherit src;

                 hackageUpdate = runCommand "hackage-update"
                   {
                     inherit hackageDb;
                     buildInputs = [ cabal-install ];
                   }
                   ''
                     # Whenever hackageDb expires, update /tmp too
                     export HOME=/tmp/tincify-home
                     [[ -d "$HOME" ]] || mkdir -p "$HOME"
                     cabal update
                     chmod +w -R "$HOME"
                     date > "$out"
                   '';

                 buildInputs = [
                   haskellTinc
                   (haskellPackages.ghcWithPackages (h: [
                     h.ghc
                     h.cabal-install
                   ]))
                   cabal2nix
                 ];

                 TINC_USE_NIX = "yes";
               } // { inherit NIX_PATH; /*Overrides withNix */ })
               ''
                 # Speed things up by storing cache in /tmp
                 export HOME=/tmp/tincify-home

                 # Force creation, e.g. if it's been deleted since hackageUpdate
                 [[ -d "$HOME" ]] || {
                   mkdir -p "$HOME"
                   cabal update
                   chmod +w -R "$HOME"
                 }

                 if [[ -d "$src" ]]
                 then
                   cp -r "$src" ./src
                 else
                   echo "Assuming $src is a tarball" 1>&2
                   mkdir ./src
                   # Extract top-level directory (whatever it's called) to ./src
                   tar xf "$src" -C ./src --strip-components 1
                 fi
                 chmod +w -R ./src

                 pushd ./src; tinc; popd

                 cp -r ./src "$out"
               '';

      deps = import "${defs}/tinc.nix" {
        nixpkgs = pkgs // { inherit haskellPackages; };
      };
    };
    deps.resolver.callPackage "${defs}/package.nix" {};
};
/*runCommand "x" { f = runCabal2nix { url = "cabal://pandoc"; }; buildInputs = [ nixMangler ]; } ''nixMangler < "$f"'' #*/ tincify
