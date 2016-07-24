{ fetchgit, stdenv }:

stdenv.mkDerivation {
  name = "md2pdf";
  src  = fetchgit {
    url    = "http://chriswarbo.net/git/md2pdf.git";
    sha256 = "1wrwx4q311ali8ksqdw1dlf4k9hr6m2ycjjjwy1ickmz4fh8gh87";
  };
  installPhase = ''
    mkdir -p "$out/bin"
    cp md2pdf "$out/bin"
    cp renderWatch "$out/bin"
    chmod +x "$out/bin"/*
  '';
}
