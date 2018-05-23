# defaultVersion is either a name, like "nixpkgs1709" or "unstable", or a
# path like <nixpkgs> which we'll use for the unstable version
defaultVersion:

with builtins;
with rec {
  # Various immutable versions of nixpkgs. defaultVersion is used to load lib.
  nixpkgs = import ./nixpkgs.nix { inherit defaultVersion; };

  # Whether defaultVersion is a nixpkgs version or a path
  customUnstable = !(elem defaultVersion ([ "unstable" ] ++ attrNames nixpkgs));

  # The nixpkgs path to use for "unstable"; if defaultVersion is a path we'll
  # use that, otherwise we'll default to the usual <nixpkgs>
  unstablePath = if customUnstable
                    then defaultVersion
                    else <nixpkgs>;

  # The name of the nixpkgs set we'll provide by default. If defaultVersion is a
  # path then we pick "unstable" in order to use that path's nixpkgs. This works
  # because unstablePath will set defaultVersion as the path for "unstable" in
  # this case. Otherwise, defaultVersion must already be a nixpkgs name
  # (possibly "unstable"!) so we return it as-is.
  defaultAttr    = if customUnstable
                      then "unstable"
                      else defaultVersion;

  stableVersion = import ./stableVersion.nix;

  inherit (getAttr stableVersion nixpkgs) lib;

  # Just the nixpkgs repos (ignores instantiated package sets, functions, etc.)
  repos = lib.filterAttrs (name: _: lib.hasPrefix "repo" name)
                          nixpkgs;

  # All of the files containing our overrides
  nixFiles = with { dir = ./custom; };
    map (f: dir + "/${f}")
        (filter (lib.hasSuffix ".nix")
                (attrNames (readDir dir)));

  # Imports the given nixpkgs path, applying our overrides. The 'unstable' flag
  # will be set for these overrides iff 'version' is "unstable". This will e.g.
  # decide whether 'latestGit' uses the latest commit of a repo or a hard-coded
  # default.
  call = repo: version: import repo {
    config = other // {
      packageOverrides = pkgs:
        with rec {
          mkPkg = x: oldPkgs:
            with rec {
              result  = import x self super;
              newPkgs = oldPkgs // result.pkgs;
              name    = lib.removeSuffix ".nix" (baseNameOf x);
            };
            assert result ? pkgs  || abort "No 'pkgs' from ${x}";
            assert result ? tests || abort "No 'tests' from ${x}";
            newPkgs // {
              # Keep a record of which packages are custom
              customPkgNames = attrNames newPkgs;

              # Accumulate any tests defined by the custom packages
              customTests = oldPkgs.customTests // {
                "${name}" = result.tests;
              };
            };

          self      = super   // overrides;
          super     = nixpkgs // pkgs // {
                        inherit customised repo stableVersion;
                      };
          overrides = lib.fold mkPkg
                               {
                                 customTests = {};
                                 stable      = version != "unstable";
                               }
                               nixFiles;

          combined  = nixpkgs // { inherit repo; } // overrides;
        };
        # Ensure that the definitions we add here are present in the result
        assert combined ? latest        || abort "No 'latest' found";
        combined;
    };
  };

  # Load each "repoFOO", applying our overrides and renaming to "nixpkgsFOO"
  customised = { unstable = call unstablePath "unstable"; } //
               lib.mapAttrs' (name: repo: {
                               name  = "nixpkgs" + lib.removePrefix "repo" name;
                               value = call repo true;
                             })
                             repos;

  other = import ./other.nix;
};
other // {
  packageOverrides = pkgs:
    with {
      result = nixpkgs // getAttr defaultAttr customised // {
        inherit customised stableVersion;
        unstable = pkgs;
      };
    };
    assert result ? customised    || abort    "'customised' not found";
    assert result ? unstable      || abort      "'unstable' not found";
    assert result ? stableVersion || abort "'stableVersion' not found";
    assert result ? latest        || abort        "'latest' not found";
    result;
}
