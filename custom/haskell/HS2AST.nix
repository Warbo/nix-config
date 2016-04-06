(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then /home/chris/Programming/repos/hs2ast.git
           else http://chriswarbo.net/git/hs2ast.git;
}
