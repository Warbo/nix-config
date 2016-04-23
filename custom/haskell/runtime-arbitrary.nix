(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then "/home/chris/Programming/repos/runtime-arbitrary.git"
           else http://chriswarbo.net/git/runtime-arbitrary.git;
}
