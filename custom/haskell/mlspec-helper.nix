self: super: with self;

haskellGit {
  url    = "${repoSource}/mlspec-helper.git";
  stable = {
    rev    = "deef213";
    sha256 = "10hp1alp5n61v56mmjpq4kag67qmswjkh7my72r58zp5l1lc74ag";
  };
}
