{ fetchurl, pythonPackages, buildPythonPackage }:

let name    = "mf2py";
    version = "1.0.2";
 in buildPythonPackage {
  inherit name version;

  src = fetchurl {
    url = "https://pypi.python.org/packages/source/m/${name}/${name}-${version}.tar.gz";
    md5 = "7fbf27173561847f74e1d0e2f885ca44";
  };

  propagatedBuildInputs = map (n: pythonPackages.${n})
                              [ "python" "html5lib" "beautifulsoup4" "requests" ];
}
