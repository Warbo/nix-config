self: super:

with builtins;
with self.lib;
with {
  inherit (self)
    fetchgit nix runCommand stdenv writeScript;
};
with rec {
  helpers = rec {

    # Forces the given derivations to be built and returns true if they work
    forceBuilds = drvs: import (withDeps drvs (writeScript "force" "true"));

    isPath = x: typeOf x == "path";

    repoSource = if getEnv "GIT_REPO_DIR" == ""
                    then "http://chriswarbo.net/git"
                    else getEnv "GIT_REPO_DIR";

    # Builds a directory whose entries/content correspond to the names/values of
    # the given attrset. When a value is an attrset, the corresponding entry is
    # a directory, whose contents is generated with attrsToDirs on that value.
    attrsToDirs =
      with rec {
        toPaths = prefix: val:
          if isPath val || isDerivation val
             then [{ name  = prefix;
                     value = val; }]
             else concatMap (entry: toPaths (prefix + "/" + entry)
                                            val."${entry}")
                            (attrNames val);

        toCmds = attrs:
          concatStringsSep "\n"
            ([''mkdir -p "$out"''] ++
             (map (entry: ''
                    mkdir -p "$(dirname "${entry.name}")"
                    ln -s "${entry.value}" "${entry.name}"
                  '')
                  (toPaths "$out" attrs)));
      };
      attrs: runCommand "merged" {} (toCmds attrs);

    # Create a directory containing 'files'; the directory structure will be
    # relative to 'base', for example:
    #
    #   dirContaining /foo/bar [ /foo/bar/baz /foo/bar/quux/foobar ]
    #
    # Will produce a directory containing 'baz' and 'quux/foobar'.
    dirContaining = base: files:
      mergeDirs (map (f: runCommand "dir"
                           {
                             base = toString base;
                             file = toString base + "/${f}";
                           }
                           ''
                             REL=$(echo "$file" | sed -e "s@$base/@@g")
                             DIR=$(dirname "$REL")
                             mkdir -p "$out/$DIR"
                             ln -s "$file" "$out/$REL"
                           '')
                     files);

    # Read the contents of a directory, building up an attrset of the paths. For
    # example, given:
    #
    #   foo/
    #     bar.html
    #     baz/
    #       quux.mp3
    #
    # We will get:
    #
    #   {
    #     foo = {
    #       "bar.html" = /path/to/foo/bar.html;
    #       baz        = {
    #         "quux.mp3" = /path/to/foo/baz/quux.mp3;
    #       };
    #     };
    #
    dirsToAttrs = dir: mapAttrs (n: v: if v == "regular"
                                          then dir + "/${n}"
                                          else dirsToAttrs (dir + "/${n}"))
                                (readDir dir);

    # Copy the contents of a bunch of directories into one
    mergeDirs = dirs: runCommand "merged-dirs" { dirs = map toString dirs; } ''
      shopt -s nullglob
      mkdir -p "$out"

      for D in $dirs
      do
        for F in "$D"/*
        do
          cp -as "$F" "$out"/
        done
        chmod +w -R "$out"
      done
    '';

    # Like fetchgit, but doesn't check against an expected hash. Useful if the
    # commit ID is generated dynamically.
    fetchGitHashless = args: stdenv.lib.overrideDerivation
      # Use a dummy hash, to appease fetchgit's assertions
      (fetchgit (args // { sha256 = hashString "sha256" args.url; }))

      # Remove the hash-checking
      (old: {
        outputHash     = null;
        outputHashAlgo = null;
        outputHashMode = null;
        sha256         = null;
      });

    reverse = lst: if lst == []
                      then []
                      else reverse (tail lst) ++ [(head lst)];

    # Remove disallowed characters from a string, for use as a name
    sanitiseName = str:
      stringAsChars (c: if elem c (lowerChars ++ upperChars)
                           then c
                           else "")
                    str;

    # True if the list xs is a suffix of the list ys, or vice versa
    suffMatch = xs: ys:
      with rec {
        lx     = length xs;
        ly     = length ys;
        minlen = if lx < ly then lx else ly;
      };
      take minlen (reverse xs) == take minlen (reverse ys);

    # Augment the environment for a derivation by allowing Nix commands to be
    # called inside the build process
    withNix = attrs:
      attrs // {
        buildInputs = (attrs.buildInputs or []) ++ [ nix ];
        NIX_PATH    = if getEnv "NIX_PATH" == ""
                         then "nixpkgs=${<nixpkgs>}"
                         else getEnv "NIX_PATH";
        NIX_REMOTE  = if getEnv "NIX_REMOTE" == ""
                         then "daemon"
                         else getEnv "NIX_REMOTE";
      };

    repo2npm = repo:
      with rec {
        inherit (self)
          callPackage nodePackages runCommand;

        converted = runCommand "convert-npm"
          {
            inherit repo;
            buildInputs = [ nodePackages.node2nix ];
          }
          ''
            cp -r "$repo" "$out"
            chmod +w -R "$out"
            cd "$out"
            node2nix
          '';
        generatedPackages = callPackage "${converted}" {};
      };
      generatedPackages.package;

    # Add extra dependencies to a derivation; for example, if we only want a
    # build to succeed if some external tests pass.
    withDeps = deps: drv: overrideDerivation drv (old: {
      extraDeps = (old.extraDeps or []) ++ deps;
    });
  };
};

helpers // { inherit helpers; }
