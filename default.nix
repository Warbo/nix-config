{ unstablePath ? <nixpkgs>, args ? {} }:

import unstablePath ({ config = import ./custom.nix unstablePath; } // args)
