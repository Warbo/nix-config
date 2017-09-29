self: super: with self;

with {
  example = stdenv.mkDerivation {
    name = "haskell-example-src";
    src  = latestGit {
      url    = "${repoSource}/writing.git";
      stable = {
        rev    = "d9cc3ad";
        sha256 = "1q0g4fvrj1an785m1zbyp4qhdqmr1hgn4cg0nf4wv7r0ffnf55af";
      };
    };
    buildCommand = ''
      source $stdenv/setup

      cp -ar "$src/TransferReport/haskell_example" "$out"
    '';
  };
};
nixFromCabal example null
