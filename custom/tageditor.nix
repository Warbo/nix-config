self: super:

with self;
with qt5;
rec {

cpputilities = stdenv.mkDerivation {
  name = "cpp-utilities";
  buildInputs = [ cmake ];
  src  = fetchFromGitHub {
    owner  = "Martchus";
    repo   = "cpp-utilities";
    rev    = "116ab9a";
    sha256 = "03pkdv3j20q2m3zwyn0750g6wdikii73v30jsw5hzn5g88k0dji5";
  };
};

qtutilities = stdenv.mkDerivation {
  name = "qt-utilities";
  buildInputs = [ cmake cpputilities full qtbase ];
  src  = fetchFromGitHub {
    owner  = "Martchus";
    repo   = "qtutilities";
    rev    = "70a9d68";
    sha256 = "1rgav7jpac0ndx3359lrr32y6yvy130lrvnc59zljmlqjmah0i03";
  };
};

tagparser = stdenv.mkDerivation {
  name = "tagparser";
  buildInputs = [ cmake cpputilities zlib ];
  src = fetchFromGitHub {
    owner  = "Martchus";
    repo   = "tagparser";
    rev    = "a6b2d10";
    sha256 = "0d3bbk8605663x2slj67xmxnzm4409z002jqyxp7cfmmnqbjidm7";
  };
};

tageditor = stdenv.mkDerivation {
  name = "tageditor";
  buildInputs = [ cmake cpputilities qtbase full qtutilities qttools tagparser ];
  src  = fetchFromGitHub {
    owner  = "Martchus";
    repo   = "tageditor";
    rev    = "09cee39";
    sha256 = "1j63cjif1zsg0byvhwy565z3d91bpm4b043b1dkv90ysgh91a08w";
  };
};

}
