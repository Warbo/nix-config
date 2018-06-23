{
  args           ? {},
  defaultVersion ? null,
  unstablePath   ? <nixpkgs>
}:

with rec {
  stableVersion = import ./stableVersion.nix;

  chosenVersion = if defaultVersion == null
                     then stableVersion
                     else defaultVersion;

  bootstrap = import unstablePath {
    config = import ./custom.nix stableVersion;
  };

  repo =
    if defaultVersion == "unstable"
       then unstablePath
       else builtins.getAttr "repo${bootstrap.lib.removePrefix "nixpkgs"
                                                               defaultVersion}"
                             bootstrap;
};

import repo ({ config = import ./custom.nix chosenVersion; } // args)
