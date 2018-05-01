{ unstablePath ? <nixpkgs>, stable ? true, args ? {} }:

import unstablePath ({
  config = import ./custom.nix (if stable
                                   then import ./stableVersion.nix
                                   else unstablePath);
} // args)
