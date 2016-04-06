(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then /home/chris/Programming/repos/lazy-smallcheck-2012.git
           else http://chriswarbo.net/git/lazy-smallcheck-2012.git;
}
