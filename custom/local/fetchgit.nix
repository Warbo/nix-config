{ nixpkgs1709 }:

# We force nixpkgs 17.09 since a change in 2016 causes hashes to be calculated
# differently. Rather than handle two hashing schemes, we just force one for
# everything.
nixpkgs1709.fetchgit
