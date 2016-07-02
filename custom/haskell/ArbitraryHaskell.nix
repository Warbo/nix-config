self: super: with self;

self.haskellGit {
  url = onOff http://chriswarbo.net/git/arbitrary-haskell.git
              "/home/chris/Programming/repos/arbitrary-haskell.git";
}
