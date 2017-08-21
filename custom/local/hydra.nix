{ fetchFromGitHub }:

with rec {
  src = fetchFromGitHub  {
    owner  = "NixOS";
    repo   = "nixpkgs-channels";
    rev    = "3badad8";
    sha256 = "0izfn9pg6jjc945pmfh20akzjpj7g95frz0rfgw2kn2g8drpfjd0";
  };

  pkgs = import src { config = {}; };
};
pkgs.hydra
