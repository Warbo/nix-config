{ mkDerivation, aeson, alex, ansi-terminal, array, base
, base64-bytestring, binary, blaze-html, blaze-markup, bytestring
, containers, data-default, deepseq-generics, Diff, directory
, executable-path, extensible-exceptions, filepath, haddock-library
, happy, highlighting-kate, hslua, HTTP, http-client
, http-client-tls, http-types, HUnit, JuicyPixels, mtl, network
, network-uri, old-locale, old-time, pandoc-types, parsec, process
, QuickCheck, random, scientific, SHA, stdenv, syb, tagsoup
, temporary, test-framework, test-framework-hunit
, test-framework-quickcheck2, texmath, text, time
, unordered-containers, vector, xml, yaml, zip-archive, zlib
}:
mkDerivation {
  pname = "pandoc";
  version = "1.13.2.1";
  sha256 = "0pvqi52sh3ldnszrvxlcq1s4v19haqb0wqh5rzn43pmqj2v6xnk6";
  isLibrary = true;
  isExecutable = true;
  buildDepends = [
    aeson alex array base base64-bytestring binary blaze-html
    blaze-markup bytestring containers data-default deepseq-generics
    directory extensible-exceptions filepath haddock-library happy
    highlighting-kate hslua HTTP http-client http-client-tls http-types
    JuicyPixels mtl network network-uri old-locale old-time
    pandoc-types parsec process random scientific SHA syb tagsoup
    temporary texmath text time unordered-containers vector xml yaml
    zip-archive zlib
  ];
  testDepends = [
    ansi-terminal base bytestring containers Diff directory
    executable-path filepath highlighting-kate HUnit pandoc-types
    process QuickCheck syb test-framework test-framework-hunit
    test-framework-quickcheck2 text zip-archive
  ];
  configureFlags = [ "-fhttps" "-fmake-pandoc-man-pages" ];
  homepage = "http://johnmacfarlane.net/pandoc";
  description = "Conversion between markup formats";
  license = "GPL";
}
