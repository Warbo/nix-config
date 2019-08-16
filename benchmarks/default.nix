# Builds the environment in which to run a benchmark. This will be called from
# asv, passing in dependencies as arguments.
{
  dir  ? ./.., # Path to the revision containing the benchmarks
  root ? ./.., # Path to the revision being benchmarked
  ...
}:

with builtins;
with {
  fixed    = import "${dir }";
  measured = import "${root}";
};

# Use 'paths' and 'vars' to pass things from 'measured' to the benchmark scripts
fixed.mkBin {
  name   = "python";
  paths  = with fixed; [ (python3.withPackages (p: [])) ];
  vars   = {};
  script = ''
    #!/usr/bin/env bash
    exec python3 "$@"
  '';
}
