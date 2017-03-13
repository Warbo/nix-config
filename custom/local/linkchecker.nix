{ buildPythonPackage, fetchFromGitHub, pythonPackages, runCommand }:

buildPythonPackage {
  name = "linkchecker";
  version = "2014-11-28";

  # Works around ridiculous hand-rolled lexicographical version-checking
  # nonsense, as per https://github.com/wummel/linkchecker/issues/649
  src = runCommand "linkchecker-patched"
    {
      pristine = fetchFromGitHub {
        owner  = "wummel";
        repo   = "linkchecker";
        rev    = "c2ce810c3fb00b895a841a7be6b2e78c64e7b042";
        sha256 = "1mbisgk57jdhshzizyh5izpqb537zjq19m5kym6apiwg0z3a8x9k";
      };
    }
    ''
      cp -r "$pristine" "$out"
      chmod +w -R "$out"
      mkdir -p "$out/doc/html"
      for F in lccollection.qhc lcdoc.qch
      do
        touch "$out/doc/html/$F"
      done
    '';

  propagatedBuildInputs = [
    pythonPackages.python
    pythonPackages.requests2
  ];

  meta = {
    description = "LinkChecker checks links in web documents or full websites.";
    homepage =  "http://wummel.github.io/linkchecker";
  };
}
