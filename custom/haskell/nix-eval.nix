(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then "/home/chris/Programming/repos/nix-eval.git"
           else http://chriswarbo.net/git/nix-eval.git;
}
