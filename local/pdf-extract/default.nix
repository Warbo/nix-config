{ lib, bundlerEnv, ruby }:

bundlerEnv {
  name = "pdf-extract-0.17.1";

  inherit ruby;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
  gemset = ./gemset.nix;

  meta = with lib; {
    description = "A monitoring framework that aims to be simple, malleable, and scalable.";
    homepage    = https://github.com/CrossRef/pdfextract;
    license     = with licenses; mit;
    platforms   = platforms.unix;
  };
}
