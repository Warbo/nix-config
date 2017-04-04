self: super:

with builtins;
with self.lib;
with {
  inherit (self)
    nix runCommand;
};
with {
  helpers = rec {

    # Builds a directory whose entries/content correspond to the names/values of
    # the given attrset. When a value is an attrset, the corresponding entry is
    # a directory, whose contents is generated with attrsToDirs on that value.
    attrsToDirs =
      with {
        inDir = d: content: runCommand "in-dir-${d}" { inherit d content; } ''
          mkdir -p "$out"
          cp -r "$content" "$out/$d"
        '';
      };
      attrs: mergeDirs (map (name: let val = attrs."${name}";
                                    in inDir name (if isAttrs val
                                                      then if val ? builder
                                                              then val
                                                              else attrsToDirs val
                                                      else val))
                            (attrNames attrs));

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
                             cp -r "$file" "$out/$REL"
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
          cp -r "$F" "$out"/
        done
        chmod +w -R "$out"
      done
    '';

    reverse = lst: if lst == []
                      then []
                      else reverse (tail lst) ++ [(head lst)];

    # Remove disallowed characters from a string, for use as a name
    sanitiseName = str:
      stringAsChars (c: if elem c (lowerChars ++ upperChars)
                           then c
                           else "")
                    str;

    # Augment the environment for a derivation by allowing Nix commands to be
    # called inside the build process
    withNix = attrs:
      attrs // {
        buildInputs = (attrs.buildInputs or []) ++ [ nix ];
        NIX_PATH    = getEnv "NIX_PATH";
        NIX_REMOTE  = getEnv "NIX_REMOTE";
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
  };
};

helpers // { inherit helpers; }
