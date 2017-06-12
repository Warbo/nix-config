{ perlPackages, stdenv }:

# Default pkg specifies a "devdoc" output then complains it wasn't made...
stdenv.lib.overrideDerivation perlPackages.MHonArc (x: { outputs = [ "out" ]; })
