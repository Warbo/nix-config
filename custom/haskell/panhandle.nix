(import <nixpkgs> {}).haskellGit {
  url = if (import <nixpkgs> {}).localOnly
           then /home/chris/Programming/repos/panhandle.git
           else http://chriswarbo.net/git/panhandle.git;
}
