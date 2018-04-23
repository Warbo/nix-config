{ autoconf, automake, fetchFromGitHub, gcc, gtk2, gtk3, hasBinary, pkgconfig,
  runCommand, stdenv, widgetThemes, withDeps }:

with rec {
  pkg = stdenv.mkDerivation {
    name = "awf";
    src  = fetchFromGitHub {
      owner  = "valr";
      repo   = "awf";
      rev    = "c937f1b";
      sha256 = "0jl2kxwpvf2n8974zzyp69mqhsbjnjcqm39y0jvijvjb1iy8iman";
    };
    buildInputs  = [ autoconf automake gcc gtk2 gtk3 pkgconfig ] ++ widgetThemes;
    preConfigure = "bash autogen.sh";
  };

  # Only expose binaries, to prevent path conflicts
  bins = runCommand "awf-binaries" { inherit pkg; } ''
    mkdir -p "$out/bin"
    for B in "$pkg/bin"/*
    do
    cp -s "$B" "$out/bin/"
    done
  '';
};

withDeps [ (hasBinary bins "awf-gtk2")
           (hasBinary bins "awf-gtk3") ]
         bins
