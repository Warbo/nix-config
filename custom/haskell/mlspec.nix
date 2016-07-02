self: super: with self;

haskellGit {
  url = onOff http://chriswarbo.net/git/mlspec.git
              "/home/chris/Programming/repos/mlspec.git";
}
