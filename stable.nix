with rec {
  # Various immutable versions of nixpkgs
  nixpkgs = import ./nixpkgs.nix;

  inherit (nixpkgs.nixpkgs1603) lib;

  # Just the nixpkgs repos (ignores instantiated package sets, functions, etc.)
  repos = lib.filterAttrs (name: _: lib.hasPrefix "repo" name ||
                                    name == "stableRepo")
                          nixpkgs;

  # Generates overrides for a package set. Also takes a bool to pick un/stable.
  custom = import ./custom.nix;

  call = repo: stable: import repo {
    config = other // {
      packageOverrides = pkgs: nixpkgs // custom stable (nixpkgs // pkgs);
    };
  };

  # Load each "repoFOO", applying our overrides and renaming to "nixpkgsFOO"
  customised = (lib.mapAttrs'
                 (name: repo: {
                   name  = if name == "stableRepo"
                              then "stable"
                              else "nixpkgs" + lib.removePrefix "repo" name;
                   value = call repo true;
                 })
                 repos) // {
                   unstable = call <nixpkgs> false;
                 };

  other = import ./other.nix;
};
other // {
  packageOverrides = pkgs: nixpkgs // customised.stable // {
    inherit customised;

    unstable = pkgs;
  };
}
