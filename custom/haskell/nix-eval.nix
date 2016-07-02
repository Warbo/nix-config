self: super: with self;

haskellGit {
  url = onOff http://chriswarbo.net/git/nix-eval.git
              "/home/chris/Programming/repos/nix-eval.git";
}
