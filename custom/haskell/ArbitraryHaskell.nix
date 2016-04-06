(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then /home/chris/Programming/repos/arbitrary-haskell.git
           else http://chriswarbo.net/git/arbitrary-haskell.git;
}
