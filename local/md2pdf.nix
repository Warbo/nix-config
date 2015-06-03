{ stdenv, pandoc, haskellPackages, panpipe, panhandle, texLiveFull,
  inotifyTools }:

stdenv.mkDerivation {
  name = "md2pdf";

  # FIXME: Should use the Git repo
  src = /home/chris/System/Programs/md2pdf;

  propagatedBuildInputs = [
    pandoc
    #haskellPackages.citeproc-hs-pandoc-filter
    haskellPackages.pandoc-citeproc
    panpipe
    panhandle
    texLiveFull
    inotifyTools
  ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp md2pdf "$out/bin/"
    cp renderWatch "$out/bin"
  '';
}
