{ gettext, fetchurl, fsuae, mesa, nixpkgs1703, mk-python-lhafile }:

with { inherit (nixpkgs1703) python3Packages; };
python3Packages.buildPythonPackage {
  name = "fs-uae-launcher";
  src  = fetchurl {
    url    = https://fs-uae.net/stable/2.8.3/fs-uae-launcher-2.8.3.tar.gz;
    sha256 = "0cx2v0cpfzwjzjby9d001xnavplzkvznx6bfnym6sl8k201n9rwc";
  };
  buildInputs           = (with python3Packages; [ wheel setuptools pip ]) ++
                          [ gettext mesa ];
  propagatedBuildInputs = [
    python3Packages.pyqt5
    (mk-python-lhafile { pythonPackages = python3Packages; })
    fsuae
  ];

  preInstall = ''
    export HOME="$out/home"
    mkdir -p "$HOME"
  '';

  DISPLAY = ":0";  # Required for tests
}
