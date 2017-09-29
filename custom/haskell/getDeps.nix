self: super: with self;

haskellGit {
  url    = "${repoSource}/get-deps.git";
  stable = {
    rev    = "cd6c171";
    sha256 = "0lxgvbk58dq4hvlh3ld5m29apf2k06ihrkv6is0q4g5fc48k88cz";
  };
}
