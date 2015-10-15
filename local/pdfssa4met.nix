{ fetchurl, pythonPackages, stdenv, pdf2xml }:

stdenv.mkDerivation {
  name = "pdfssa4met";
  version = "2010-03";

  src = fetchurl {
    url = https://pdfssa4met.googlecode.com/files/pdfssa4met.tgz;
    sha256 = "1x0vx8q6vmcanrk8asxs55hac8f4cwiy19krnqc3m1nbjha7l3zp";
  };

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.lxml
  ];

  installPhase = ''
    # Copy to lib/ and symlink executables to bin/
    mkdir -p "$out/lib"
    mkdir -p "$out/bin"
    cp -r . "$out/lib/pdfssa4met"
    for SCRIPT in pdf2xml.py headings.py references.py socialtags.py
    do
      ln -s "$out/lib/pdfssa4met/$SCRIPT" "$out/bin/$SCRIPT"
      chmod +x "$out/bin/$SCRIPT"
    done

    # Patch the location in config.py
    sed -i "$out/lib/pdfssa4met/config.py" -e 's@/usr/local/bin/pdftoxml.linux.exe.1_2_4@${pdf2xml}/bin/pdftoxml@g'
  '';

  meta = {
    description = "PDF Structure and Syntactic Analysis for Metadata Extraction and Tagging";
    homepage =  " https://code.google.com/p/pdfssa4met";
  };
}
