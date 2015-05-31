{ mkDerivation, base, bytestring, containers, directory, filepath
, stdenv, terminfo, transformers, unix, utf8-string
}:
mkDerivation {
  pname = "haskeline";
  version = "0.7.2.1";
  sha256 = "09v4vy6nf23b13ws9whdqwv84mj1nhnla88rw2939qyqxb4a6mmf";
  buildDepends = [
    base bytestring containers directory filepath terminfo transformers
    unix utf8-string
  ];
  configureFlags = [ "-fterminfo" ];
  homepage = "http://trac.haskell.org/haskeline";
  description = "A command-line interface for user input, written in Haskell";
  license = stdenv.lib.licenses.bsd3;
}
