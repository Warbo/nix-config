self: super:

with {
  # Update this as you like, when some packages become out-of-date (e.g. when
  # some online API has made a breaking change)
  rev = "8a391e1d70cf95dc9a3df428e2e17e8ead3b6a78";
  sha256 = "0c287s8jvkp2y8q1m1zm3d1izra2y51fnhmpd27pp7j9cn3vcswb";
}; {
  overrides = {
    nixpkgsUpstream =
      import
        (fetchTarball {
          inherit sha256;
          name = "nixpkgs-${rev}";
          url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
        })
        {
          config = { };
          overlays = [ ];
        };
  };
  tests = { };
}
