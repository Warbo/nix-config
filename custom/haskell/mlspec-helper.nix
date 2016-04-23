(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then "/home/chris/Programming/repos/mlspec-helper.git"
           else http://chriswarbo.net/git/mlspec-helper.git;
}
