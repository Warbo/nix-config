(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then "/home/chris/Programming/repos/mlspec.git"
           else http://chriswarbo.net/git/mlspec.git;
}
