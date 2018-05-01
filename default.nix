{
  args           ? {},
  defaultVersion ? import ./stableVersion.nix,
  unstablePath   ? <nixpkgs>
}:

import unstablePath ({ config = import ./custom.nix defaultVersion; } // args)
