self: super: with self;

haskellGit {
  url    = "${repoSource}/mlspec-helper.git";
  stable = {
    rev    = "d794706";
    sha256 = "0vlr3ar1zwk0ykbzmg47j1yv1ba8gf6nzqj10bfy60nii91z7slh";
  };
}
