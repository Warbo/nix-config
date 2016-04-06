(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then /home/chris/Programming/repos/ml4hsfe.git
           else http://chriswarbo.net/git/ml4hsfe.git;
}
