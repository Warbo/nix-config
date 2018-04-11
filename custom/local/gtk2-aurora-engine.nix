{ fetchFromGitHub, gtk2, pkgconfig, runCommand, stdenv }:

with rec {
  repo = fetchFromGitHub {
    owner  = "ScoreUnder";
    repo   = "gtk-aurora-engine-fixed";
    rev    = "b7f9308";
    sha256 = "115jp3mwax3q9dj5gflnyasllhlv54qwgwipc7ca1h4b3bw1adml";
  };

  engine = stdenv.mkDerivation {
    name        = "gtk-aurora-engine";
    src         = "${repo}/aurora-1.5";
    buildInputs = [ gtk2 pkgconfig ];
  };

  theme = "${repo}/Aurora";

  combined = runCommand "aurora-engine"
    {
      inherit engine theme;
    }
    ''
      cp -r "$engine" "$out"
      chmod +w -R "$out"
      mkdir -p "$out/share/themes"
      cp -r "$theme" "$out/share/themes/Aurora"
    '';
};
combined
