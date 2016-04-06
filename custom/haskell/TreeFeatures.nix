(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then /home/chris/Programming/repos/tree-features.git
           else http://chriswarbo.net/git/tree-features.git;
}
