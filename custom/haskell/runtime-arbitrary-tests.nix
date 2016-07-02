self: super: with self;

haskellGit {
  url = onOff http://chriswarbo.net/git/runtime-arbitrary-tests.git
              "/home/chris/Programming/repos/runtime-arbitrary-tests.git";
}
