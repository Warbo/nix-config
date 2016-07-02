self: super: with self;

haskellGit {
  url = onOff http://chriswarbo.net/git/get-deps.git
              "/home/chris/Programming/repos/get-deps.git";
}
