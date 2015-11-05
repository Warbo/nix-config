{ fetchurl, pythonPackages, stdenv, subdist, translitcodec }:

stdenv.mkDerivation {
  name = "pdfmeat";
  version = "2014-11-28";

  src = /home/chris/System/Programs/pdfmeat;

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.anyjson
    pythonPackages.sqlite3
    subdist
    translitcodec
  ];

  meta = {
    description = "PDF MEtadata Acquisition Tool (aka pdftobibtex/pdf2bibtex)";
    homepage =  " https://code.google.com/p/pdfmeat/downloads/list";
  };

  installPhase = ''
    mkdir -p "$out/bin"
    cp pdfmeat.py "$out/bin/pdfmeat"
  '';
}
