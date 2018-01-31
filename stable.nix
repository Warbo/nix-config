with rec {
  # Various immutable versions of nixpkgs
  nixpkgs = import ./nixpkgs.nix;

  inherit (nixpkgs.nixpkgs1603) lib;

  # Just the nixpkgs repos (ignores instantiated package sets, functions, etc.)
  repos = lib.filterAttrs (name: _: lib.hasPrefix "repo" name)
                          nixpkgs;

  # Generates overrides for a package set. Also takes a bool to pick un/stable.
  custom = import ./custom.nix;

  call = repo: packagesVersion: import repo {
    config = other // {
      packageOverrides = pkgs: nixpkgs // custom (packagesVersion != "unstable")
                                                 (nixpkgs // pkgs // {
                                                   inherit customised
                                                           packagesVersion;
                                                 });
    };
  };

  # Load each "repoFOO", applying our overrides and renaming to "nixpkgsFOO"
  customised = (lib.mapAttrs'
                 (name: repo:
                   with {
                     packagesVersion = lib.removePrefix "repo" name;
                   };
                   {
                     name  = "nixpkgs" + lib.removePrefix "repo" name;
                     value = call repo true;
                   })
                 repos) // {
                   unstable = call <nixpkgs> "unstable";
                 };

  other = import ./other.nix;

  # Bump this to upgrade everything which doesn't hard-code its nixpkgs version
  defaultVersion = customised.nixpkgs1603;
};
other // {
  packageOverrides = pkgs: nixpkgs // defaultVersion // {
    inherit customised;

    unstable = pkgs;
  };
}
