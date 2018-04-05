# defaultVersion is either a name, like "nixpkgs1709" or "unstable", or a
# path like <nixpkgs> which we'll use for the unstable version
defaultVersion:

with builtins;
with rec {
  # Various immutable versions of nixpkgs. defaultVersion is used to load lib.
  nixpkgs = import ./nixpkgs.nix { inherit defaultVersion; };

  # Whether defaultVersion is a nixpkgs version or a path
  customUnstable = !(elem defaultVersion ([ "unstable" ] ++ attrNames nixpkgs));

  unstablePath = if customUnstable
                    then defaultVersion
                    else <nixpkgs>;

  defaultAttr    = if customUnstable
                      then "unstable"
                      else defaultVersion;

  inherit (nixpkgs.nixpkgs1709) lib;

  # Just the nixpkgs repos (ignores instantiated package sets, functions, etc.)
  repos = lib.filterAttrs (name: _: lib.hasPrefix "repo" name)
                          nixpkgs;

  nixFiles = with { dir = ./custom; };
    map (f: dir + "/${f}")
        (filter (lib.hasSuffix ".nix")
                (attrNames (readDir dir)));

  call = repo: version: import repo {
    config = other // {
      packageOverrides = pkgs:
        with rec {
          mkPkg = x: oldPkgs:
            with { newPkgs = oldPkgs // import x self super; };
            newPkgs // {
              # Keep a record of which packages are custom
              customPkgNames = attrNames newPkgs;
            };

          self      = super   // overrides;
          super     = nixpkgs // pkgs // { inherit customised repo; };
          overrides = lib.fold mkPkg { stable = version != "unstable"; }
                               nixFiles;
        };
        nixpkgs // { inherit repo; } // overrides;
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
  packageOverrides = pkgs: nixpkgs // (getAttr defaultAttr customised) // {
    inherit customised;

    unstable = pkgs;
  };
}
