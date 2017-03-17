{ buildGoPackage, fetchFromGitHub, fetchgx, writeScript }:

buildGoPackage rec {
  name = "ipns-pub";
  version = "2016-10-25";

  goPackagePath = "github.com/whyrusleeping/ipns-pub";

  src = fetchFromGitHub {
    owner  = "whyrusleeping";
    repo   = "ipns-pub";
    rev    = "2adb372";
    sha256 = "0pw67gv4ib3ccf45a4x3v5cnk83d0hykbqn45a774pv1hry1jlgf";
  };

  extraSrcPaths = [
    (fetchgx {
      inherit name src;
      sha256 = "0pjl9r2lh8hmhz56v4wkbg3dlx84ifb8if96aadh2s365wipn0mb";
    })
  ];
}
