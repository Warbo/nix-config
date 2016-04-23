(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then "/home/chris/Programming/repos/get-deps.git"
           else http://chriswarbo.net/git/get-deps.git;
}
