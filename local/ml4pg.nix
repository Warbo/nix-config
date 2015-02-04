{ stdenv, fetchgit, emacs }:

stdenv.mkDerivation (rec {
  name = "ProofGeneral-4.3pre131011";

  src = fetchgit {
    url = http://proofgeneral.inf.ed.ac.uk/releases/ProofGeneral-4.3pre131011.tgz;
    sha256 = "0104iy2xik5npkdg9p2ir6zqyrmdc93azrgm3ayvg0z76vmnb816";
  };

  sourceRoot = name;

  buildInputs = [ proofgeneral emacs openjdk graphviz ];

  meta = {
    description = "Machine Learning for Proof General, an AI assistant for theorem proving";
    longDescription = ''
      ML4PG applies machine-learning methods to formal proofs, via the Emacs-based Proof General
      interface. It finds similarities between proofs based on structure, tactic usage, etc. and
      presents them as clusters, graphs and automata.
    '';
    homepage = http://staff.computing.dundee.ac.uk/katya/ML4PG;
  };
})
