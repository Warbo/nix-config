# Fixed versions of pandoc, panpipe, panhandle, pandoc-citeproc and dependencies
{ attrsToDirs, cabal-install, fetchFromHackage, gcc, ghc, haskell, haskellNewBuild, installHackage, latestGit, lib, nixListToBashArray, pkgconfig, repoSource, runCommand, unzip, writeScript, zlib }:

with lib;
with rec {
  hSet = haskellPkgsDeps {
    deps = [
      "base >= 4.8"
      "pandoc-citeproc == 0.10.4"
      "panpipe == 0.2.0.0"
      "panhandle == 0.3.0.0"
      "aeson == 0.11.3.0"
      "attoparsec == 0.13.1.0"
      "tasty == 0.11.2.1"
      "lazysmallcheck2012"
      "pandoc"
    ];

    extra-sources = [
      haskell.packages.ghc7103.lazysmallcheck2012.src
      (latestGit {
        url    = "${repoSource}/panhandle.git";
        stable = {
          rev    = "7e44d75";
          sha256 = "1cgk5wslbr507fmh1fyggvk15lipa8x815392j9qf4f922iifdzn";
        };
      })
    ];

    hsPkgs = haskell.packages.ghc7103;

    useOldZlib = true;
  };

  wanted = hSet.ghcWithPackages (h: [
    h.pandoc
    h.panpipe
    h.pandoc-citeproc
    h.panhandle
  ]);

  deps = {
    pandoc          = "1.17.2";
    pandoc-citeproc = "0.10.4";
    panhandle       = "0.3.0.0";
    panpipe         = "0.2.0.0";
  };

  getDep = name: version: fetchFromHackage { inherit name version; };

  cabalFile = writeScript "dummy.cabal" ''
    name:                dummy
    version:             1
    synopsis:            Dummy for building
    description:         Dummy for building
    homepage:            http://chriswarbo.net/projects/repos/reduce-equations.html
    license:             PublicDomain
    author:              Chris Warburton
    maintainer:          chriswarbo@gmail.com
    build-type:          Simple
    cabal-version:       >=1.10

    library
      build-depends:     ${concatStringsSep ", "
                             (["base"] ++ (map (n: n + " == " + getAttr n deps)
                                               (attrNames deps)))}
      hs-source-dirs:      .
      default-language:    Haskell2010
  '';

  build = name: version: haskellNewBuild {
    inherit name;
    extra-inputs = [ gcc pkgconfig unzip zlib zlib.dev ];
    pkg          = "${name}-${version}";
  };

  dirs = nixListToBashArray {
    args = attrValues (mapAttrs build deps);
    name = "dirs";
  };
};

runCommand "pandocPkgs"
  dirs.env
  ''
    ${dirs.code}

    mkdir -p "$out/bin"
    for DIR in "$dirs[@]"
    do
      cp -sv "$DIR"/bin/* "$out/bin"
    done
  ''
/*haskellNewBuild {
  dir = attrsToDirs (mapAttrs getDep deps // { "dummy.cabal" = cabalFile; });
  name = "pandocPkgs";
}
*/
