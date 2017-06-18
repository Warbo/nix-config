self: super: with self;

haskellGit {
  url = "${repoSource}/ifcxt.git";
  ref = "constraints";
}
