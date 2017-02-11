{ git, fetchurl, nodePackages, stdenv }:

stdenv.mkDerivation {
  name = "riot";
  src  = fetchurl {
    url    = "https://github.com/vector-im/riot-web/archive/v0.9.7.tar.gz";
    sha256 = "11g24gg6xbh9qk7w34fp55zdvwvc5mjb0ppafszlca36sasg9m0c";
  };
  buildInputs = [ git nodePackages.npm ];
  buildPhase  = ''
    export HOME="$PWD"
    npm install
    #(cd node_modules/matrix-js-sdk && npm install)
    #(cd node_modules/matrix-react-sdk && npm install)

    cat config.sample.json
    #npm run dist
  '';
}
