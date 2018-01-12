{ latestGit, repoSource, stdenv }:

stdenv.mkDerivation {
  name = "md2pdf";
  src  = latestGit {
    url    = "${repoSource}/md2pdf.git";
    stable = {
      rev    = "ee98157";
      sha256 = "1wrwx4q311ali8ksqdw1dlf4k9hr6m2ycjjjwy1ickmz4fh8gh87";
    };
  };
  installPhase = ''
    mkdir -p "$out/bin"
    cp md2pdf "$out/bin"
    cp renderWatch "$out/bin"
    chmod +x "$out/bin"/*
  '';
}
