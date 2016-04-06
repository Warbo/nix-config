{ fetchurl, stdenv, latestGit }:

stdenv.mkDerivation {
  name = "engauge-digitizer";
  src = latestGit {
    url = https://github.com/markummitchell/engauge-digitizer.git;
  };
}
