self: super:

with self;
with rec {
  src = fetchFromGitHub {
    owner  = "nick8325";
    repo   = "genifunctors";
    rev    = "797482d948a00dd80f6c0236ac1d1f28fca56c68";
    sha256 = "0mfna7jsx9hkg6c4wg41bqxgphww839gx0q5amrwbl249kwn8518";
  };
};

nixFromCabal src null
