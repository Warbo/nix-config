self: super: with self; with builtins;

haskellGit {
  url = onOff http://chriswarbo.net/git/panpipe.git
              "/home/chris/Programming/repos/panpipe.git";
}
